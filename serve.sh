#!/usr/bin/env bash

VERSION="0.1.0"
SCRIPT_NAME="serve"

print_help() {
  cat <<EOF
${SCRIPT_NAME} v${VERSION}
Tiny Bash HTTP server for files and directories.

Usage:
  ./serve.sh [TARGET]
  PORT=9000 ./serve.sh [TARGET]
  ./serve.sh --help

Examples:
  ./serve.sh
  ./serve.sh html
  ./serve.sh html/index.html
  PORT=3000 ./serve.sh html
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  print_help
  exit 0
fi

if [[ "${1:-}" == -* ]]; then
  echo "Error: unknown option '$1'. Use --help for usage." >&2
  exit 1
fi

PORT=${PORT:-8080}
TARGET="${1:-.}"

if [ ! -e "$TARGET" ]; then
  echo "Error: '$TARGET' does not exist." >&2; exit 1
fi

# ── helpers ────────────────────────────────────────────────────────────────

mime_type() {
  case "${1##*.}" in
    html|htm) echo "text/html"               ;;
    css)      echo "text/css"                ;;
    js)       echo "application/javascript"  ;;
    json)     echo "application/json"        ;;
    xml)      echo "application/xml"         ;;
    svg)      echo "image/svg+xml"           ;;
    png)      echo "image/png"               ;;
    jpg|jpeg) echo "image/jpeg"              ;;
    gif)      echo "image/gif"               ;;
    ico)      echo "image/x-icon"            ;;
    webp)     echo "image/webp"              ;;
    txt|md)   echo "text/plain"              ;;
    pdf)      echo "application/pdf"         ;;
    zip)      echo "application/zip"         ;;
    *)        echo "application/octet-stream";;
  esac
}

url_decode() {
  local v="${1//+/ }"
  printf '%b' "${v//%/\\x}"
}

send() { printf '%s\r\n' "$@"; }   # write HTTP header lines

# ── request handler (one request per invocation) ──────────────────────────

handle_request() {
  local root="$1" is_file="$2"

  # Read & parse request line
  read -r req_line
  req_line="${req_line%$'\r'}"
  read -r _method req_path _ver <<< "$req_line"
  req_path=$(url_decode "${req_path%%\?*}")   # strip query string

  # Drain headers
  while IFS= read -r hdr; do
    [[ "${hdr%$'\r'}" == "" ]] && break
  done

  # Resolve target path
  local full
  if [[ "$is_file" == "1" ]]; then
    full="$root"
  else
    # Prevent path traversal
    full=$(realpath -sm "$root/$req_path" 2>/dev/null || echo "$root/$req_path")
    if [[ "$full" != "$root"* ]]; then
      send "HTTP/1.1 403 Forbidden" "Content-Type: text/plain" "Connection: close" ""
      printf 'Forbidden'
      return
    fi
  fi

  # ── 404 ──
  if [[ ! -e "$full" ]]; then
    local body="<html><body><h1>404 Not Found</h1><p>${req_path}</p></body></html>"
    send "HTTP/1.1 404 Not Found" \
         "Content-Type: text/html" \
         "Content-Length: ${#body}" \
         "Connection: close" ""
    printf '%s' "$body"
    return
  fi

  # ── directory listing ──
  if [[ -d "$full" ]]; then
    # Prefer index.html
    if [[ -f "$full/index.html" ]]; then
      full="$full/index.html"
    else
      local body
      body="<html><head><title>Index of ${req_path}</title>
<style>body{font-family:monospace;padding:1em}a{display:block}</style></head>
<body><h2>Index of ${req_path}</h2><hr>"
      [[ "$req_path" != "/" ]] && body+='<a href="../">../</a>'
      while IFS= read -r entry; do
        local name; name=$(basename "$entry")
        [[ -d "$entry" ]] && name+="/"
        body+="<a href=\"${name}\">${name}</a>"
      done < <(find "$full" -maxdepth 1 ! -path "$full" | sort)
      body+="<hr></body></html>"
      send "HTTP/1.1 200 OK" \
           "Content-Type: text/html" \
           "Content-Length: ${#body}" \
           "Connection: close" ""
      printf '%s' "$body"
      return
    fi
  fi

  # ── regular file ──
  local ct size
  ct=$(mime_type "$full")
  size=$(wc -c < "$full")
  send "HTTP/1.1 200 OK" \
       "Content-Type: ${ct}" \
       "Content-Length: ${size}" \
       "Connection: close" ""
  cat "$full"
}

export -f handle_request mime_type url_decode send

# ── setup ──────────────────────────────────────────────────────────────────

LISTENER=""
if command -v nc &>/dev/null; then
  LISTENER="nc"
elif command -v socat &>/dev/null; then
  LISTENER="socat"
elif command -v ncat &>/dev/null; then
  LISTENER="ncat"
else
  echo "Error: one of 'nc', 'socat', or 'ncat' is required." >&2
  exit 1
fi

IS_FILE=0; [[ -f "$TARGET" ]] && IS_FILE=1

# Absolute path
if [[ "$IS_FILE" == "1" ]]; then
  TARGET=$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")
else
  TARGET=$(cd "$TARGET" && pwd)
fi

FIFO=$(mktemp -u /tmp/srv_XXXXXX)
mkfifo "$FIFO"
trap 'rm -f "$FIFO"; exit' INT TERM EXIT

echo "Serving : $TARGET"
echo "URL     : http://localhost:$PORT"
echo "Listener: $LISTENER"
echo "Stop    : Ctrl+C"

# ── main loop ──────────────────────────────────────────────────────────────
# Pattern: handle_request < FIFO | listener > FIFO
#   • listener receives HTTP request from client → writes it into FIFO
#   • handle_request reads request from FIFO → writes response into the pipe
#   • listener reads response from the pipe → sends it to the client

listen_once() {
  case "$LISTENER" in
    nc)
      nc -l -p "$PORT" > "$FIFO" 2>/dev/null || nc -l "$PORT" > "$FIFO" 2>/dev/null
      ;;
    socat)
      socat "TCP-LISTEN:${PORT},reuseaddr" STDIO > "$FIFO" 2>/dev/null
      ;;
    ncat)
      ncat -l "$PORT" > "$FIFO" 2>/dev/null || ncat --listen "$PORT" > "$FIFO" 2>/dev/null
      ;;
  esac
}

while true; do
  bash -c "handle_request '$TARGET' '$IS_FILE'" < "$FIFO" \
    | listen_once
done
