---
description: "Use when adding features, changing behavior, fixing bugs, or refactoring serve.sh; require SemVer version bumps by updating VERSION with strict MAJOR.MINOR.PATCH format only."
applyTo: "serve.sh"
---
# Serve Script Version Bump Rule

When implementing a feature, changing behavior, fixing a bug, or performing a pure refactor in `serve.sh`, always update the `VERSION` value in the same change.

Use Semantic Versioning 2.0.0:
- `MAJOR`: incompatible or breaking behavior changes.
- `MINOR`: backward-compatible feature additions or enhancements.
- `PATCH`: backward-compatible bug fixes and refactors with no behavior change.

Version format must be strictly `MAJOR.MINOR.PATCH`.
Do not use pre-release or build metadata (for example `1.2.0-rc.1` or `1.2.0+build.1`).

Do not leave the version unchanged when qualifying code changes are made.
