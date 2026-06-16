# Structured logging

UAPKB uses [Pino](https://getpino.io/) via `lib/logger.ts`.

## Behavior

- **Production:** JSON logs to stdout (fly.io captures them). No worker-thread transport.
- **Development:** `pino-pretty` for human-readable output.
- **Level:** `LOG_LEVEL` env var (default `info`).

## Next.js caveat

Do not use Pino worker-thread transport in Next.js — bundling/serverless breaks it. Keep logging in Node route handlers, not Edge middleware.

## Call sites

`/healthz` logs each request at `info` with `{ route, status }`. Import `logger` from `@/lib/logger` for new server-side call sites.

## Future

No log aggregation shipper in v1 — stdout only. Add dashboards/shippers when operational needs arise.
