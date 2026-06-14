# Code quality

## Two-layer model

- **Prettier** owns formatting (`.prettierrc`, `.editorconfig` floor).
- **ESLint** owns code quality (`eslint.config.mjs`).
- **`eslint-config-prettier` is applied last** so the tools never fight.

## Lint debt ratchet

Ratcheted rules are `error` level. Existing violations are grandfathered in `eslint-suppressions.json`.

| Script                         | Purpose                                     |
| ------------------------------ | ------------------------------------------- |
| `pnpm lint`                    | Fail on new violations (`--max-warnings 0`) |
| `pnpm lint:suppress`           | Widen baseline (`eslint --suppress-all`)    |
| `pnpm lint:prune-suppressions` | Narrow baseline                             |

New violations fail CI's ESLint check. Touching grandfathered code without adding violations stays green.

## Local gates

See `PRINCIPLES.md` §5 and `scripts/check.sh`. Coverage gates run in CI only — see `docs/coverage.md`.
