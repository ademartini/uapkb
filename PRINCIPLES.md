# Engineering Principles

This repository is a reference for building software in an AI-first way without giving up the
fundamentals that make software safe to change. The goal is not to describe good practices — it is
to wire them up so they actually run. Everything below is enforced somewhere in this repo: in a
lint rule, a hook, a CI check, or a deployment gate. If a principle here isn't backed by a
mechanism, treat that as a bug.

A guiding idea runs through all of it: **an agent is just another contributor who reads your repo
literally and never asks twice.** What is ambiguous to an agent is ambiguous to a new teammate. What
you have to remember to do by hand, you will eventually forget. So we make the environment
deterministic, encode rules where they're enforced, and let the machine hold the line.

## 1. Determinism and environment parity

The most expensive class of bug is "works on my machine." It is not fixed by discipline; it is fixed
by removing the variables.

- The development environment should mirror CI and production as closely as possible. This repo runs
  the **same container locally and in CI**, and pins the **same language runtime** all the way
  through to the production image.
- Production runs a slim, separate image — parity is achieved by **pinning identical runtime
  versions**, not by shipping the dev container to production. That trade-off is deliberate and
  stated, not accidental.
- One command takes a fresh clone to a running app with passing tests. If setup takes a paragraph of
  prose, it takes a script instead.
- Verify from a clean context: a fresh clone, a rebuilt container, a new machine, a new agent
  session. If it only works from your shell history, it isn't reproducible yet.

> If it works on your machine but fails elsewhere, it's not fixed yet.

## 2. Two layers: format, then lint

Formatting and code quality are different jobs, and conflating them creates noise.

- A **formatter** (Prettier) owns whitespace, quotes, and line breaks. It makes no judgments; it just
  applies a single style so nobody argues about it.
- A **linter** (ESLint) owns code quality: dead code, unsafe patterns, accessibility, hook rules.
- The formatter config is applied **last** in the lint setup so the two tools never fight over the
  same bytes. Never route formatting through the linter.

> The point isn't the style. The point is giving up the argument.

> Gofmt's style is no one's favorite, yet gofmt is everybody's favorite. — Rob Pike

## 3. Ratchet debt in one direction

You rarely get to fix everything at once. You can almost always stop it from getting worse.

- Record the current count of a problem, block any increase, and let the count fall as people fix
  things. The floor only moves toward zero.
- This repo ratchets lint debt with native bulk suppressions: existing violations are grandfathered;
  a new one fails the build. Widening or narrowing that floor is a deliberate, reviewable change.
- The same shape applies to coverage, type strictness, complexity, and dead code. Start by stopping
  the bleeding, then drive the number down through normal work.

## 4. Tests are a floor under velocity, not a vanity metric

Coverage does not prove your tests are good. It proves which lines a test never touched.

- Hold **new and changed code** to a high bar; hold the **project total** to "must not decrease."
  Chasing the last few percent of an old codebase is worth less than never shipping new untested
  code.
- Prefer branch coverage to line coverage — it is the signal that survives AI-generated code best.
- A passing suite is the thing that lets an agent — or a person — refactor without fear. That is what
  coverage buys: the freedom to move.

> Test coverage is of little use as a numeric statement of how good your tests are. — Martin Fowler

## 5. Layered gates, and a ladder for encoding rules

Catch problems at the cheapest point, but never rely on the cheap points alone.

| Stage            | What runs                             | Why                              |
| ---------------- | ------------------------------------- | -------------------------------- |
| Editor / on-save | Formatter, fast lints                 | Free feedback while typing       |
| Pre-commit       | Formatter + lint on staged files      | Catch before it's committed      |
| Pre-push         | Format check, lint, type-check, tests | Last chance before it leaves     |
| CI (required)    | Everything, whole repo, check-only    | The source of truth — no opt-out |

The earlier stages are conveniences. **CI is the only contract.**

When you learn a lesson, encode it at the lowest level that catches the failure:

1. A **lint rule or pre-commit hook** — deterministic, fails the build.
2. A **tool/agent hook** — fires on every edit or end-of-turn.
3. A **skill or sub-agent** — codified, but not enforced.
4. **Prose in an agent doc** — a soft reminder, and the last resort.

> Hooks fail loudly. Prose fades.

Prose decays in a long agent session the same way a sticky note decays on a monitor. If a rule must
apply _every time_, it belongs in a hook, not an instruction.

## 6. CI is named, fast, and honest

- Each concern is its own **named check**: format, type-check, test, lint. A reviewer should see
  `Prettier ✓ / TypeScript ✗ / ESLint ✓`, not one opaque "build" line.
- CI runs in check mode — it verifies, it never rewrites your code.
- A flaky check is worse than no check, because people learn to ignore it. Keep CI fast and
  trustworthy; quarantine flakes, don't paper over them with blanket retries.
- New checks can start non-blocking to establish a baseline, then flip to blocking once the signal is
  clean.

## 7. Small, focused changes

Small changes are easier to review, easier to roll back, and easier to hand to an agent with a clear
acceptance criterion. Decompose large work into independently shippable slices with explicit "done"
conditions rather than one sprawling branch.

## 8. Smoke tests are behavioral assertions

A health check tells you the server booted. A smoke test tells you it actually works.

- A smoke test exercises a critical path end to end and asserts on behavior — not `curl /health`.
- Keep it to **5–15 minutes of signal** on the journeys that matter, not the full suite.
- Wire it into the pipeline as a hard gate. Fail-closed is not a promise in a document; it's an `if:`
  condition in the workflow that refuses to promote a broken build.

## 9. Deploy automatically, promote on proof, roll back on a runbook

- Merging to the default branch deploys an environment with no manual steps.
- Promotion to production happens **because a smoke test passed**, not because someone clicked a
  button. Green staging earns production automatically; a red smoke stops the line.
- Deployment is triggerable programmatically (e.g. `workflow_dispatch`) and documented, so an agent
  can deploy and so can you.
- Rollback starts as a runbook clear enough that an agent could execute it, and grows toward
  automatic rollback on a failed smoke or a monitoring alert. Remember what a redeploy _cannot_ undo:
  schema changes, sent emails, charged cards.

## 10. Observability you can query, not just read

- Emit **structured logs** with consistent levels and a propagated trace ID, so a slice of a request
  can be reconstructed instead of grepped.
- Make the health endpoint informative: version, commit, and dependency state — enough to answer
  "what is actually running right now?"
- Expose signal through saved queries and APIs rather than firehoses. An agent that has to read ten
  thousand log lines has already lost the plot; give it the aggregate.

## 11. Pin everything

- Commit lockfiles. Pin the package manager via `packageManager`. Pin the runtime via `.nvmrc` and
  `engines`.
- Pin third-party CI actions to a commit SHA, with the human-readable version in a comment. **Pin to
  a SHA, not a branch** — a branch push silently changes what everyone runs.
- Pin container base images and features by digest where reproducibility matters; leave a base image
  on a floating patch tag only when you specifically want its security updates.
- Stay within one major version of current, supported releases. Bump deliberately, in their own PRs.

## 12. Build for agents as first-class contributors

- A root **`AGENTS.md`** is the single entry-point: the build/test/lint commands, the directory map,
  the conventions, and the safety boundaries. Keep it short and use pointers, not copies — the
  commands live in `package.json`, the doc just names them.
- Restrict what agents can see. `.cursorignore` keeps secrets and generated artifacts out of agent
  context — it is **context hygiene, not a security boundary** (terminal and MCP tools bypass it).
  Real secrets stay out of the workspace; `.gitignore` controls version control.
- Work in a **Research → Plan → Implement** rhythm: understand before you plan, plan before you
  write. Workflow matters more than prompt wording for the quality of what comes out.
- The test of a good agent setup is simple: a fresh session, reading only the committed docs, gets to
  a green build and a passing test on its own. If it has to ask, the answer belonged in the repo.
