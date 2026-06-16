---
date: 2026-06-13
topic: uapkb-scaffolding
---

# UAPKB Scaffolding — Requirements

## Summary

Stand up UAPKB as a greenfield TypeScript/Next.js reference repository that demonstrates AI-first and general engineering best practices end to end: a quality stack with coverage and lint ratchets, a Cursor-native dev setup, a containerized local environment with Postgres, named CI checks on pull requests, and continuous deployment to fly.io across staging and production with smoke-gated automatic promotion. This first effort delivers scaffolding only — no application domain logic and no ORM. A single distilled principles doc captures the engineering philosophy without referencing any external course or program.

## Problem Frame

A reference repository teaches more by being run than by being read. An earlier Next.js sample app established a strong quality core (Vitest, ESLint/Prettier two-layer, a lint ratchet, husky gates, a devcontainer, named CI jobs) but stopped at dev-plus-CI — it has no database, no production image, and no deployment, and it is wired for Claude Code rather than Cursor. The cost of that gap is that the most instructive practices — reproducible environment parity across dev/CI/prod, smoke-gated promotion, agent-accessible deployment — are described in prose but never demonstrated in a repo someone can clone and watch work. UAPKB closes that gap: every practice it teaches is wired and exercised, not just documented.

## Key Decisions

- **Build on the prior scaffold's quality core, re-skinned for Cursor.** Port the proven Vitest / ESLint / Prettier / husky setup and the lint ratchet rather than rebuilding them; translate the Claude Code agent configuration to Cursor equivalents. Net-new work concentrates on the database, the production image, and deployment.

- **Parity is by version pinning, not one literal image.** Dev and CI genuinely share the `.devcontainer`; fly.io production runs a separate slim multi-stage image. They stay in parity because the same Node and pnpm versions are pinned everywhere — not because the devcontainer ships to production. This is stated explicitly in the repo as a deliberate, explained choice.

- **One pinned Node version across all three environments.** The prior repo ran the devcontainer on Node 22 and CI on Node 20. UAPKB pins a single Node version (and pnpm version via `packageManager`) across devcontainer, CI, and the production Dockerfile to remove that drift.

- **Neon is the remote Postgres target but stays unprovisioned.** Local development runs Postgres via Docker Compose. The app reads `DATABASE_URL` and treats it as optional; staging and production define the variable as a placeholder pointing at a future Neon instance that is not created in this effort. No ORM, schema, or migrations.

- **Production auto-promotes on a green staging smoke test.** A merge to the default branch deploys staging, runs the smoke test, and — on success — automatically deploys production. This demonstrates full continuous-deployment progression rather than a manual approval gate.

- **A distilled principles doc replaces external references.** One markdown file states the guiding principles and key engineering ideas in the repo's own voice. It does not reference, name, or allude to any training, cohort, course, or educational program. The repository is framed purely as a reference for AI-first development.

- **Deterministic enforcement is preferred over prose.** Where a rule must hold every time, it is encoded at the lint, hook, or CI layer rather than as an instruction in an agent doc. The agent entry-point documents commands and conventions; it is not the enforcement mechanism.

- **Post-deploy smoke uses Playwright, not bare HTTP checks.** A minimal `@smoke`-tagged Playwright suite exercises critical paths against the deployed staging URL after deploy. This matches the teaching goal that smoke tests are behavioral assertions, not "did the process start."

- **The health endpoint defines a dependency-status contract up front; wiring checks is incremental.** The response shape includes overall status, build metadata (version/commit), and a `dependencies` object listing each dependency with its own status. For now the only dependency is the database. The contract is implemented from day one; an actual Postgres connectivity check is deferred — until wired, the database entry reports `not_configured` when `DATABASE_URL` is absent and can be upgraded to a real check when Neon is provisioned.

## Requirements

### Project foundation and stack

R1. The repo is a Next.js App Router application in TypeScript with `strict: true`, using pnpm pinned via the `packageManager` field, and Tailwind v4 (CSS-first, no `tailwind.config.js`).

R2. `next.config.ts` sets `output: 'standalone'` so the production image can ship the minimal standalone server.

R3. A single Node version is pinned and used identically by the devcontainer, CI, and the production Dockerfile; the pin is recorded in a form CI and local tooling both read (e.g. `.nvmrc` and/or `engines`).

R4. Quality-stack dev dependencies are exact-pinned (no `^`); bumping them is a deliberate change.

R5. The repo contains no application domain logic, no ORM, and no UAP feature beyond what the scaffold itself needs (a health endpoint and a minimal landing page are acceptable).

### Code quality and ratcheting

R6. Formatting and linting follow a two-layer model: Prettier owns formatting; ESLint owns code quality; `eslint-config-prettier` is applied last so the two never conflict. EditorConfig provides the mechanical whitespace/EOL floor.

R7. Lint debt is ratcheted via ESLint native bulk suppressions: a committed suppressions baseline grandfathers existing violations, new violations fail, and `suppress` / `prune` scripts are provided to widen or narrow the floor deliberately in a PR.

R8. Lint runs with zero-warning tolerance (`--max-warnings 0`).

R9. Supply-chain hygiene files are present: `.gitattributes` for LF normalization, a `.git-blame-ignore-revs` template, and `pnpm-workspace.yaml` configured to block unwanted postinstall scripts.

### Testing and coverage

R10. Vitest is configured with React Testing Library and jsdom, a shared setup file, the `@/` path alias mirrored from `tsconfig.json`, and coverage via the v8 provider with sensible excludes (test files, type decls, route shell files).

R11. Coverage is enforced as a gate with a measured threshold, and the configuration demonstrates the ratcheting pattern (the project floor cannot decrease; new/changed code is held to a higher bar). The starting numbers are set from a real baseline rather than aspiration.

R12. Test-placement conventions are documented and followed: collocated unit tests next to source, cross-cutting tests in a `tests/` directory, and no `*.test.tsx` under `app/`.

R13. Playwright is configured for end-to-end smoke tests, with a `@smoke` tag on the minimal post-deploy subset. The suite runs against a configurable base URL (local, staging, or production) and completes within the 5–15 minute smoke budget.

### Local development environment

R14. A `.devcontainer` defines the local and CI environment: a floating base image (for OS security patches) with SHA-pinned features and a committed feature lock file, installs run via `updateContentCommand` with `--frozen-lockfile`, and the Next.js dev port is forwarded.

R15. A Docker Compose stack runs Postgres for local development. The database starts via a documented single command and is the only live database in this effort.

R16. The devcontainer composes with the Postgres service so a contributor gets the app environment and the database together, and credentials/state persist appropriately across container rebuilds.

R17. A single documented command performs clone-to-running: install, start services, and run tests, exercising the deterministic-setup loop.

### Cursor and AI-first configuration

R18. A root `AGENTS.md` is the canonical agent entry-point: build/test/lint commands, directory map, architectural conventions, and safety boundaries, kept concise and using pointers rather than copies. A `CLAUDE.md` symlink may be provided for cross-tool reach.

R19. Deterministic agent enforcement is wired via Cursor hooks (`.cursor/hooks.json`): format and lint-fix on file edits, and a full local gate at end-of-turn equivalent to the CI checks.

R20. A `.cursorignore` restricts agent access to secrets and generated artifacts (`.env*`, build output, `node_modules`).

R21. The devcontainer provides the Cursor CLI (replacing the prior repo's Claude Code feature) with appropriate credential persistence.

### Continuous integration

R22. GitHub Actions runs on pull requests with separate named checks — formatting, type-check, test (with coverage), and lint — so each appears as a distinct pass/fail line.

R23. A devcontainer-CI job builds the same `.devcontainer` and runs the production build inside it, proving the container image builds and the build works in it.

R24. A job builds the production Docker image on pull requests to prove the deploy artifact is buildable (parity with what fly.io will ship).

R25. All third-party GitHub Actions are SHA-pinned with the human-readable version recorded in a comment, and a documented bump procedure.

### Production image and fly.io deployment

R26. A multi-stage `Dockerfile` produces a slim production image from the standalone output, accompanied by a `.dockerignore` that keeps `node_modules`, `.git`, and dev files out of the build context.

R27. The production server binds the port fly.io expects and respects the platform's `PORT` convention.

R28. The app exposes a `/healthz` endpoint returning structured JSON with: overall `status`, build metadata (`version`, `commit`), and a `dependencies` object. Each dependency entry has a `name` and `status`. The only dependency in this effort is `database`. When `DATABASE_URL` is absent, `database.status` is `not_configured` and the overall status remains healthy. A real connectivity check is deferred — the response shape is stable from day one so callers and smoke tests can depend on it.

R29. Environment configuration is explicit: a committed `.env.example`, runtime handling of `DATABASE_URL` as optional, and documented placement of secrets in fly.io rather than the repo.

R30. Two fly.io environments exist — staging and production — each with its own configuration and a `DATABASE_URL` placeholder for the future Neon target.

### Deployment progression and smoke tests

R31. A merge to the default branch deploys staging automatically with no manual steps.

R32. After staging deploy, the Playwright `@smoke` suite runs against the staging URL. It asserts behavioral paths (e.g. the landing page renders, `/healthz` returns the expected dependency-status shape), not merely that the process started. The run completes within the 5–15 minute smoke budget.

R33. On a green staging smoke, production deploys automatically; on a failed smoke, production does not deploy.

R34. Deployment is agent-accessible: the deploy workflow is triggerable via `workflow_dispatch` and the trigger is documented in `AGENTS.md`. A rollback procedure is documented as a runbook structured enough for an agent to execute.

### Guiding principles document

R35. A single markdown file states the repository's guiding principles and key engineering ideas in its own voice, covering at minimum: deterministic/reproducible environments and parity; the two-layer format/lint model; coverage as a floor with ratcheting; named CI checks and the "CI is the contract" stance; the layered-gates and enforcement-ladder model (prefer lint/hook over prose); small focused changes; smoke tests as behavioral assertions; environment promotion and rollback; structured logging and a queryable health endpoint; version/dependency pinning; and the AGENTS.md-as-entry-point, RPI-style workflow for AI-first development.

R36. The principles doc contains no reference to any training, cohort, course, program, or educational material — only engineering practices and their rationale.

## Key Flows

F1. **Pull-request verification.** A contributor opens a PR. CI runs formatting, type-check, test+coverage, and lint as separate named checks; the devcontainer build job and the production-image build job run in parallel. All must pass for merge.

F2. **Merge-to-production progression.** A merge to the default branch triggers a staging deploy to fly.io → the smoke test runs against staging → on success, production deploys automatically → (a failed staging smoke stops the pipeline before production).

## Acceptance Examples

AE1. **Covers R28, R15.** With `DATABASE_URL` unset (as in unprovisioned staging/production), `GET /healthz` returns HTTP 200 with overall `status: "ok"`, build metadata present, and `dependencies.database.status: "not_configured"`. The smoke test asserts this shape.

AE2. **Covers R28 (future).** When a real database connectivity check is wired and Postgres is reachable, `dependencies.database.status` becomes `"ok"`. When `DATABASE_URL` is set but Postgres is unreachable, it becomes `"error"` and overall status reflects degraded health. This behavior is not required in the first scaffolding effort.

AE3. **Covers R32, R33.** When the Playwright `@smoke` suite passes against staging, production deploys in the same pipeline run. When it fails, the pipeline stops and production retains its prior version.

AE4. **Covers R7.** When a new lint violation is introduced that is not in the suppressions baseline, CI's lint check fails. When an existing grandfathered violation is touched but not increased in count, the lint check passes.

AE5. **Covers R3.** The Node version reported inside the devcontainer, in the CI runner, and in the production image is identical.

## Success Criteria

- A fresh clone reaches a running app and a passing test suite using only the documented single command and `AGENTS.md`, within a few minutes and without the contributor asking questions the docs should have answered.
- After executing the eventual plan, a maintainer can merge a trivial PR and watch it flow green through PR checks, staging deploy, smoke, and automatic production deploy.
- A reader of the principles doc cannot tell the repository originated from any course or program.

## Scope Boundaries

### Deferred for later

- Drizzle/ORM, database schema, and migrations.
- Actual UAP/UFO knowledge-base domain features.
- Provisioning the Neon database and wiring real production secrets.
- A live Postgres connectivity check in `/healthz` (the response shape is in scope; the actual query is deferred until Neon is provisioned).
- Monitoring/observability tooling (structured-logging libraries, APM, agent-queryable telemetry) beyond the health endpoint and the principle stated in the doc.
- A full end-to-end test suite beyond the minimal Playwright `@smoke` subset; per-PR preview environments.

### Outside this repository's identity

- It is not a tutorial or course companion; it carries no training, cohort, or program references.
- It is not a multi-service monorepo or a domain-complete product; it is a single-app reference scaffold.

## Dependencies / Assumptions

- The GitHub repository will be created later in the user's personal org; the repo can be built locally first and pushed when ready.
- fly.io accounts/apps for staging and production, and their deploy tokens, are configured outside the repo when deployment is first run; the scaffold provides the configuration and workflows, not the live secrets.
- The deployed app does not depend on the database in this effort, so staging and production can run with `DATABASE_URL` unset and still pass the smoke test.

## Outstanding Questions

### Deferred to planning

- Exact starting coverage threshold numbers and whether to wire automatic threshold ratcheting versus a fixed floor initially.
- Which Playwright smoke scenarios ship in v1 beyond landing-page render and `/healthz` shape assertion.
- fly.io specifics: app naming, regions, machine sizing, and whether staging and production share one `fly.toml` with overrides or use separate files.
- Cursor credential-persistence mechanism in the devcontainer (named volume vs alternative) and which VS Code/Cursor extensions to preinstall.
- Whether Playwright runs in CI on every PR or only in the post-deploy pipeline (recommendation: PR subset optional, post-deploy `@smoke` required).

## Sources / Research

- Prior Next.js scaffold (closest reference for the quality core, devcontainer, CI, and hooks): `../xplor-test-app` — notably `package.json`, `vitest.config.ts`, `eslint.config.mjs`, `.devcontainer/devcontainer.json`, `.github/workflows/quality-checks.yml`, `.github/workflows/devcontainer-ci.yml`, `.husky/`, `scripts/check.sh`, `docs/code-quality.md`. It lacks all production/deploy artifacts (Dockerfile, fly.toml, compose DB, health endpoint, env handling) and is wired for Claude Code, not Cursor.
- Sequential environment-promotion CI pattern (reusable workflows, one gate per environment, concurrency groups): the agentic-readiness dashboard repo's `.github/workflows/`.
- Best-practice substance feeding the principles doc and the requirements thresholds (coverage gates and ratcheting, named CI checks, layered gates and the enforcement ladder, smoke-as-behavioral-assertion, deterministic build/parity, version pinning, AGENTS.md as entry-point): the engineering rubric criteria (C1–C18) and the W-series engineering decks. These inform the doc but are not referenced from inside the repository.
