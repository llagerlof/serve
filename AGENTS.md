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

- `PORT` env var support with default `8080`.
- `TARGET` argument behavior:
- Directory target: resolve requested path beneath root.
- File target: always serve that file.
- `index.html` precedence in directories.
- Auto-generated directory listing when no index exists.
- Proper 404 response for missing files.
- Proper 403 response for blocked traversal attempts.
- MIME type detection for common extensions.

## Validation Checklist

After edits, agents should verify:

1. `./serve.sh html` starts without errors.
2. `curl -i http://localhost:8080/` returns `200`.
3. `curl -i http://localhost:8080/does-not-exist` returns `404`.
4. `curl -i "http://localhost:8080/../etc/passwd"` returns `403`.
5. Directory listing appears for folders without `index.html`.

## Documentation Policy

- Keep `README.md` aligned with actual behavior.
- Update examples when CLI or defaults change.
- Call out limitations clearly (local/dev use only).
