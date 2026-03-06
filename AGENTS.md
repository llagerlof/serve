# AGENTS.md

Guidance for coding agents working in this repository.

## Repository Purpose

This repo contains a minimal Bash HTTP server (`serve.sh`) using netcat, plus a small static HTML example under `html/`.

## Key Files

- `serve.sh`: main server implementation
- `html/index.html`: demo static page
- `README.md`: end-user documentation
- `.github/instructions/docs-sync.instructions.md`: doc-sync rule for Copilot instructions

## Agent Goals

- Keep the project simple and dependency-light.
- Preserve compatibility with common `nc` variants.
- Favor readability over clever shell constructs.
- Avoid introducing framework-level complexity.

## Editing Rules

- Prefer small, targeted patches.
- Keep scripts POSIX-friendly where practical, but Bash is allowed and currently required.
- Do not remove path traversal protection.
- Do not break single-file serving mode.
- Keep the fallback `nc` listener pattern intact unless replacing it with a proven cross-platform approach.

## Functional Expectations

Any change to `serve.sh` should preserve:

- Auto port selection when no explicit port is provided: start at `10000`, then increment by `1000`.
- Explicit port support via `--port`; if occupied, exit with a non-zero error.
- `TARGET` argument behavior:
- Directory target: resolve requested path beneath root.
- Non-HTML file target: always serve that file.
- HTML file target (`.html`/`.htm`): serve its parent directory and print URL with that HTML path suffix.
- `index.html` precedence in directories.
- Auto-generated directory listing when no index exists.
- Proper 404 response for missing files.
- Proper 403 response for blocked traversal attempts.
- MIME type detection for common extensions.
- UTF-8 charset in `Content-Type` for textual responses.

## Validation Checklist

After edits, agents should verify:

1. `./serve.sh html` starts without errors.
2. Use the printed URL port from startup output, then verify `curl -i http://localhost:<port>/` returns `200`.
3. Use the same printed port and verify `curl -i http://localhost:<port>/does-not-exist` returns `404`.
4. Use the same printed port and verify `curl -i "http://localhost:<port>/../etc/passwd"` returns `403`.
5. Directory listing appears for folders without `index.html`.
6. `./serve.sh --port <busy-port>` exits non-zero with a port-in-use error.

## Documentation Policy

- Keep `README.md` aligned with actual behavior.
- Update examples when CLI or defaults change.
- Call out limitations clearly (local/dev use only).
