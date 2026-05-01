# serve web server

A tiny Bash HTTP server for local file and directory sharing.

## Quick start

- Run `serve` from the directory you want to expose, or pass a path explicitly.
- Open the URL printed at startup in your browser.

## Installation

Clone the repository into `~/repos`, then link the script into `~/.local/bin` so it is available on your `PATH`.

```bash
mkdir -p ~/repos
git clone https://github.com/llagerlof/serve.git ~/repos/serve
mkdir -p ~/.local/bin
ln -sf ~/repos/serve/serve ~/.local/bin/serve
```

If `~/.local/bin` is not already on your `PATH`, add it in your shell profile before opening a new shell.

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

Run from anywhere after installing, or from the repository that should be served.

```text
$ serve [TARGET]
$ serve --port 9000 [TARGET]
$ serve --help
```

`TARGET` is optional and defaults to the current directory (`.`).

`TARGET` can be one of these:

- A directory: serves files rooted at that directory.
- A single non-HTML file: always serves that file, regardless of request path.
- An HTML file: serves the file's parent directory and prints a startup URL that includes that HTML path.

When you omit `--port`, `serve` picks the first free port in the sequence `10000`, `11000`, `12000`, and so on.

When you pass `--port`, that port must already be free or the script exits with an error.

At startup, the `Listener:` line shows which backend was chosen: `socat`, `ncat`, or `nc`.

## Examples

Serve the current directory:

```bash
serve
```

Serve the `html` directory on a fixed port:

```bash
serve --port 9000 html
```

Serve an absolute path:

```bash
serve --port 8080 /var/www/html/
```

Serve a single HTML file and open the printed URL:

```bash
serve html/index.html
```

Show help and version:

```bash
serve --help
```

## Notes

- Press `Ctrl+C` to stop.
- This is intended for local development/testing, not production deployment.
