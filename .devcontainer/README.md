# Devcontainer

See `docs/devcontainer.md` for the full guide. This directory holds:

- `devcontainer.json` — shared local + CI environment
- `devcontainer-lock.json` — SHA-pinned feature lock

First-run: `npx @devcontainers/cli@latest up --workspace-folder .` from repo root.

Rebuild/reopen the devcontainer after changing `devcontainer.json`; the `node_modules`
volume must be mounted before the dependency install runs.

Cursor Cloud Agents use `.cursor/environment.json` and `.cursor/Dockerfile` instead of this devcontainer.
