# serve.sh web server

A tiny shell script (linux bash) that is a web server.

## Quick start

- `cd` into directory to be served and run the `serve.sh` script. Done.

- Access `http://localhost:10000` in a browser.

## Features

- Serves a directory via http.
- Serves `index.html` when present in directory.
- Generates a simple directory listing if no `index.html` exists.
- Auto-selects an available port starting at `10000`, then `11000`, `12000`, and so on.
- Supports explicit port selection via `--port`.
- Resolves common MIME types (`html`, `css`, `js`, images, etc.).
- Sends `charset=utf-8` for textual content types to avoid browser encoding issues.
- Prevents directory traversal outside the target root.
- Prefers `socat` or `ncat` when available so overlapping browser asset requests do not reset the connection.

## Requirements

The server uses the first available listener in this order: `socat`, `ncat`, then `nc`.

One of these programs must be installed:

- `socat`
- `ncat`
- `nc` (netcat)

## Usage

Run from project root:

```
./serve.sh [TARGET]
./serve.sh --port 9000 [TARGET]
./serve.sh --help
```

- `TARGET` optional, defaults to current directory (`.`)
  - `TARGET` can be:
  - a directory (serve files under it)
  - a single non-HTML file (always serves that file)
  - an HTML file (serves that file's directory, and prints a URL ending in that HTML path)

## Examples

**Set a custom port and serves directory `html` that exists in current directory:**

```
$ serve.sh --port 9000 html
```
Then open on browser `http://localhost:9000`

**You also can pass the full path:**
```
$ serve.sh --port 8080 /var/www/html/
```

If no port is provided, the script picks the first free port in the sequence `10000`, `11000`, `12000`, ...

If you explicitly set a port with `--port` and it is already in use, the script exits with an error.

If multiple listener tools are installed, the startup `Listener:` line shows which one was selected.

**Show help/version:**

```
$ serve.sh --help
```

## Examples

**Serve current directory:**

```
$ serve.sh
```

**Serve one file only (file's directory is still accessible):**

```
$ serve.sh html/calculator.html
```

## Notes

- Press `Ctrl+C` to stop.
- This is intended for local development/testing, not production deployment.
