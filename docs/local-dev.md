# Local development

## Prerequisites

- Docker (for the devcontainer and optional Postgres)
- Node 22 + pnpm 10 (if not using devcontainer)

Enable pnpm explicitly — do not assume corepack ships with your Node distribution:

```bash
corepack enable pnpm
```

## Clone to running

```bash
git clone <repo-url> uapkb && cd uapkb
npx @devcontainers/cli@latest up --workspace-folder .
npx @devcontainers/cli@latest exec --workspace-folder . pnpm install --frozen-lockfile
npx @devcontainers/cli@latest exec --workspace-folder . pnpm test:run
npx @devcontainers/cli@latest exec --workspace-folder . pnpm dev
```

## Postgres

Start the database only when working on database-backed behavior. The current devcontainer does not start Docker Compose automatically, and the app reports the database as `not_configured` when `DATABASE_URL` is unset.

```bash
docker compose up -d db
```

Connection string (see `.env.example`):

```
DATABASE_URL=postgres://uapkb:uapkb@localhost:5432/uapkb
```

Data persists in the `uapkb-postgres-data` volume across `docker compose down` / `up`.

## Environment variables

Copy `.env.example` to `.env.local` for local overrides. `DATABASE_URL` is optional until Neon is provisioned.
