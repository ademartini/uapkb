# Production rollback runbook

fly.io has **no** `flyctl releases rollback`. Rollback means redeploying a prior image.

## Steps

1. List recent releases with image refs:

   ```bash
   fly releases --image --app uapkb-production
   ```

2. Identify the last known-good image ref from the list.

3. Redeploy that image:

   ```bash
   fly deploy --image <image-ref> --config fly.production.toml --app uapkb-production
   ```

4. Verify:

   ```bash
   curl -s https://uapkb-production.fly.dev/healthz | jq .
   pnpm test:smoke
   ```

   (Set `PLAYWRIGHT_BASE_URL` to production only if explicitly intended.)

## What rollback does NOT revert

- **fly.toml config changes** already applied stay in effect unless you redeploy from a branch with the old config.
- **Secrets** are not rolled back.
- **Database migrations** are not rolled back.
- **Old images** may be pruned by the registry — keep note of good image refs in deploy logs.

## When to use

- Staging smoke passed but production shows regressions (rare — same digest ships).
- Production-only config drift.
- Need to hot-fix by reverting to last green image while a fix is prepared.
