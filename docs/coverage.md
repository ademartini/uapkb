# Coverage gates

Two independent gates — both run in CI, neither in local hooks.

## 1. Repo-wide ratchet (Vitest `autoUpdate`)

`vitest.config.ts` sets `coverage.thresholds.autoUpdate` with integer flooring. When a run beats recorded thresholds, Vitest rewrites the numbers — **commit that change in your PR**.

CI runs coverage then:

```bash
git diff --exit-code vitest.config.ts
```

- Coverage **drop** → Vitest threshold failure
- Coverage **gain** without committed config → git-diff guard failure

Regenerate locally:

```bash
pnpm coverage:update
```

### Why not a bot committing to main?

Elevated credentials, polluted history, bypasses review. The developer-owned PR commit is the recognized pattern.

### Why not Codecov / stale diff actions?

Third-party SaaS sign-up ruled out; JS-native diff-coverage actions are abandoned (barecheck 2021–22). A ~50-line repo script is transparent and reviewable.

## 2. Changed-line minimum (`scripts/check-diff-coverage.mjs`)

Intersects Vitest `lcov.info` `DA:` lines with added lines from:

```bash
git diff --diff-filter=d -M --unified=0 origin/<base>...HEAD
```

Default threshold: 80% (`DIFF_COVERAGE_THRESHOLD`).

Edge cases:

- **Empty diff** → pass
- **Comment/type-only edits** → not in lcov denominator → not penalized
- **Deletions** → diff gate scores added lines only
- **Renames** → `-M` follows new path

## Dead-code deletion

Removing well-covered code can lower the global %. That surfaces as a visible threshold change in the PR — intentional and reviewable. The diff gate does not fire on deletions.
