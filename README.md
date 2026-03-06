# serve.sh Web Server

A tiny Bash web server powered by `nc`, `socat`, or `ncat`.

## What It Does

- Serves a single file or a whole directory.
- Uses `PORT` environment variable (default: `8080`).
- Resolves common MIME types (`html`, `css`, `js`, images, etc.).
- URL-decodes request paths.
- Prevents directory traversal outside the target root.
- Serves `index.html` when present in directories.
- Generates a simple directory listing if no `index.html` exists.

## Requirements

- Linux or Unix-like shell environment
- `bash`
- One of the following listeners available on `PATH`:
- `nc` (`netcat`) preferred
- `socat` fallback
- `ncat` fallback

## Usage

Run from project root:

```bash
./serve.sh [TARGET]
./serve.sh --help
```

- `TARGET` optional, defaults to current directory (`.`)
- `TARGET` can be:
- a directory (serve files under it)
- a single file (always serves that file)

Set a custom port:

```bash
PORT=9000 ./serve.sh html
```

Then open:

```text
http://localhost:9000
```

Show help/version:

```bash
./serve.sh --help
```

## Examples

Serve project root:

```bash
./serve.sh
```

Serve only `html/`:

```bash
./serve.sh html
```

Serve one file only:

```bash
./serve.sh html/index.html
```

## Current Project Content

- `serve.sh`: Bash HTTP server (supports `nc`, `socat`, or `ncat`)
- `html/index.html`: sample page

## Notes

- The server handles one connection per loop iteration.
- Press `Ctrl+C` to stop.
- Listener selection order is `nc` -> `socat` -> `ncat`.
- If `nc -l -p <port>` is unsupported, script falls back to `nc -l <port>`.
- Script version is `0.1.0`.
- This is intended for local development/testing, not production deployment.
