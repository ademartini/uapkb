#!/usr/bin/env bash
set -euo pipefail

if [[ "${CI:-}" != "true" ]]; then
  curl https://cursor.com/install -fsS | bash
fi

sudo chown -R node:node /home/node/.cursor /home/node/.config/gh

# Keep browser-test development ready inside the devcontainer. System
# dependencies need root; browser binaries should stay in the node user's cache.
sudo env PATH="$PATH" pnpm exec playwright install-deps chromium
pnpm exec playwright install chromium
