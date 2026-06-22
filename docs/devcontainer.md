# Environment contracts

UAPKB has four environment surfaces. They share runtime pins, but they are not the same contract:

1. **Local/editor** — `.devcontainer/devcontainer.json` for Cursor GUI and `@devcontainers/cli`
2. **CI devcontainer** — `.devcontainer/devcontainer.json` through `devcontainers/ci` in `.github/workflows/quality-checks.yml`
3. **Cursor Cloud Agent** — `.cursor/environment.json` plus `.cursor/Dockerfile`
4. **Production** — root `Dockerfile` for the fly.io image

## Devcontainer

The local/CI devcontainer is consumed three ways:

1. **Cursor GUI** — "Reopen in Container" (`anysphere.remote-containers`)
2. **CLI** — `@devcontainers/cli` (`devcontainer up` / `exec`) — **canonical first-run path**
3. **CI** — `devcontainers/ci` in `.github/workflows/quality-checks.yml`

## Parity claim

CI runs named checks inside the same devcontainer image local development uses. A `devcontainer-build` job rebuilds from the PR's `.devcontainer` (GHCR image is `cacheFrom` only, not the run image).

Cursor Cloud Agents and production use separate Dockerfiles. Parity is by **pinned Node/pnpm versions** (`.nvmrc`, `package.json` `packageManager`, the root Dockerfile `ARG`, `.cursor/Dockerfile`, and the devcontainer base), guarded by `scripts/check-node-parity.sh` and the Cloud image build check in CI.

## Caveats

- Containerized CI is near-parity, not perfect (runner host kernel/network differ).
- Cursor GUI devcontainer reopen is the least reliable consumer — prefer the CLI path.
- The devcontainer does not start Docker Compose automatically. Start Postgres explicitly with `docker compose up -d db` only when needed.
- `postAttachCommand` is GUI-only; shared setup lives in `updateContentCommand` / `postCreateCommand`.
- `node_modules` is mounted as a named volume, and pnpm's store lives under that volume. `onCreateCommand` makes the volume writable before `updateContentCommand` installs dependencies.
- Playwright Chromium dependencies and browser binaries are installed by `.devcontainer/post-create.sh` so browser tests can be developed inside the container without one-off host setup.

## Cursor CLI

Installed via `postCreateCommand` (`curl https://cursor.com/install`). Auth:

- **Local:** `agent login` (credentials in named volume `cursor-config-${devcontainerId}`)
- **CI:** `CURSOR_API_KEY` GitHub Environment secret (not repo-wide — fork PRs cannot read it)

## Cursor Cloud Agents

Cursor Cloud Agents use `.cursor/environment.json`, not `.devcontainer/devcontainer.json`. The repo-level Cloud config takes precedence over saved personal or team environments and points to `.cursor/Dockerfile`; paths in the `build` block are relative to `.cursor`, while `install` runs from the project root.

Cloud setup is intentionally no-secret by default:

- Dependencies refresh with `pnpm install --frozen-lockfile`.
- The acceptance gate is `pnpm check`.
- No Postgres, `DATABASE_URL`, fly.io token, GitHub token, or local Cursor credential is required for the app or `/healthz` to boot.
- Secret values belong in Cursor Secrets for Cloud-only needs, GitHub Environment secrets for CI, fly.io secrets for deploys, or local `.env.local` for local overrides. Do not commit them.

Start a new Cloud setup run or rebuild the Cloud environment when `.cursor/environment.json`, `.cursor/Dockerfile`, `.nvmrc`, `package.json` `packageManager`, or system packages change. Dependency-only changes should be handled by the idempotent install step.

Cloud setup files run before normal task execution in a remote worker. Treat `.cursor/environment.json` and `.cursor/Dockerfile` as privileged review surfaces, and only start secret-enabled Cloud runs from trusted branches.

## Cursor Cloud acceptance checklist

Record this checklist from a fresh no-secret Cloud Agent run on the branch containing the Cloud config. Do not commit transient setup logs, shell history, machine paths, or snapshot IDs as evidence.

- Repo-level `.cursor/environment.json` was selected instead of a saved personal/team environment.
- Cloud runtime reports Node 22 and pnpm 10.18.3.
- `pnpm install --frozen-lockfile` ran from the repository root and was idempotent on rerun.
- `pnpm check` passed with `DATABASE_URL`, Cursor auth state, GitHub tokens, and fly.io tokens unset.
- Setup output, generated files, and snapshot notes contain no secret values.
- Any secret-enabled Cloud run records who reviewed the secret access scope and why the secret was needed.
- If a secret value appears in Cloud logs, shell history, generated artifacts, or snapshot notes, rotate the secret; deleting the workspace or snapshot is not enough.

## GitHub CLI

Installed via the official Dev Containers `github-cli` Feature. Auth:

- **Local:** `gh auth login --hostname github.com --git-protocol ssh --web` (credentials in named volume `github-cli-config-${devcontainerId}`)
- **Git credential helper:** `gh auth setup-git --hostname github.com` after login when HTTPS Git operations should use `gh`
- **CI/headless:** set `GH_TOKEN` for the command invocation; do not bake GitHub tokens into the devcontainer image

## Cursor Browser

`pnpm dev` binds Next.js to `0.0.0.0:60517` so Cursor/VS Code port forwarding can expose the app from the container. Port `60517` is configured with `requireLocalPort: true`, making `http://localhost:60517` the stable URL for the Cursor browser, browser automation tools, and agents. The container's internal network URL is not portable across hosts.

If Cursor shows a different random forwarded URL, port `60517` was already unavailable or the container needs to be rebuilt/reopened after config changes. Free the local port, then rebuild/reopen the devcontainer so the port forward can bind to `localhost:60517`.

If the browser cannot reach the app:

1. Confirm the dev server is running with `pnpm dev`.
2. Confirm port `60517` is forwarded in the Ports panel.
3. Confirm Cursor Browser Automation is enabled in Cursor settings.
