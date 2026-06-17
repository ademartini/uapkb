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

## GitHub CLI

Installed via the official Dev Containers `github-cli` Feature. Auth:

- **Local:** `gh auth login --hostname github.com --git-protocol ssh --web` (credentials in named volume `github-cli-config-${devcontainerId}`)
- **Git credential helper:** `gh auth setup-git --hostname github.com` after login when HTTPS Git operations should use `gh`
- **CI/headless:** set `GH_TOKEN` for the command invocation; do not bake GitHub tokens into the devcontainer image

## Private registry pattern

See commented guidance in `.devcontainer/devcontainer.json` for forwarding host tokens via `remoteEnv`.

## Cursor Browser

`pnpm dev` binds Next.js to `0.0.0.0:60517` so Cursor/VS Code port forwarding can expose the app from the container. Port `60517` is configured with `requireLocalPort: true`, making `http://localhost:60517` the stable URL for the Cursor browser, browser automation tools, and agents. The container's internal network URL is not portable across hosts.

If Cursor shows a different random forwarded URL, port `60517` was already unavailable or the container needs to be rebuilt/reopened after config changes. Free the local port, then rebuild/reopen the devcontainer so the port forward can bind to `localhost:60517`.

If the browser cannot reach the app:

1. Confirm the dev server is running with `pnpm dev`.
2. Confirm port `60517` is forwarded in the Ports panel.
3. Confirm Cursor Browser Automation is enabled in Cursor settings.
