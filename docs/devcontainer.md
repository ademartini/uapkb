# Devcontainer

One `.devcontainer/devcontainer.json` is consumed three ways:

1. **Cursor GUI** — "Reopen in Container" (`anysphere.remote-containers`)
2. **CLI** — `@devcontainers/cli` (`devcontainer up` / `exec`) — **canonical first-run path**
3. **CI** — `devcontainers/ci` in `.github/workflows/quality-checks.yml`

## Parity claim

CI runs named checks inside the same devcontainer image local development uses. A `devcontainer-build` job rebuilds from the PR's `.devcontainer` (GHCR image is `cacheFrom` only, not the run image).

Production runs a separate slim Docker image; parity is by **pinned Node/pnpm versions** (`.nvmrc`, Dockerfile `ARG`, devcontainer base), guarded by `scripts/check-node-parity.sh`.

## Caveats

- Containerized CI is near-parity, not perfect (runner host kernel/network differ).
- Cursor GUI devcontainer reopen is the least reliable consumer — prefer the CLI path.
- `postAttachCommand` is GUI-only; shared setup lives in `onCreate` / `updateContent` / `postCreate`.

## Cursor CLI

Installed via `onCreateCommand` (`curl https://cursor.com/install`). Auth:

- **Local:** `agent login` (credentials in named volume `cursor-config-${devcontainerId}`)
- **CI:** `CURSOR_API_KEY` GitHub Environment secret (not repo-wide — fork PRs cannot read it)

## Private registry pattern

See commented guidance in `.devcontainer/devcontainer.json` for forwarding host tokens via `remoteEnv`.
