# Deployment

## Environments

| Environment | Config                | fly app            |
| ----------- | --------------------- | ------------------ |
| Staging     | `fly.staging.toml`    | `uapkb-staging`    |
| Production  | `fly.production.toml` | `uapkb-production` |

`internal_port = 3000` matches Dockerfile `ENV PORT=3000`.

## Secrets

Set per-app fly secrets — **never** in `[env]` or the repo:

```bash
fly secrets set DATABASE_URL="postgres://placeholder" --app uapkb-staging --stage
```

`DATABASE_URL` is a placeholder until Neon is provisioned. Absence at runtime is valid — `/healthz` reports `not_configured`.

Also set build metadata for `/healthz`:

```bash
fly secrets set APP_VERSION="1.0.0" APP_COMMIT="<sha>" --app uapkb-staging
```

Deploy tokens live in GitHub Environment secrets: `FLY_API_TOKEN_STAGING`, `FLY_API_TOKEN_PRODUCTION`.

## Promotion (image by digest)

Merge to `main` triggers `.github/workflows/deploy.yml`:

1. Build + push production image once → digest
2. Deploy staging with that image
3. Run `@smoke` against staging URL
4. On green smoke → deploy production with **same image**

Smoke validates the exact artifact production receives — not a second independent build.

Manual trigger: GitHub Actions → `deploy` → **Run workflow**.

## Agent access

Documented in `AGENTS.md`. Rollback: `docs/runbook-rollback.md`.

## Action SHA bumps

Pin third-party actions to full commit SHA with `# vX.Y.Z` comment. Bump via `pinact` or Dependabot `github-actions` ecosystem.
