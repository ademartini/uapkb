# Shared PATH setup for Cursor hooks. Hooks run in a non-login shell, so profile
# files like .zshrc may not have populated PATH.
repo_root="${CURSOR_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$repo_root"

# Common binary locations for macOS hosts and Linux devcontainers.
extra_path="$HOME/.local/bin:$HOME/.cursor/bin:/usr/local/bin"
if [ -d /opt/homebrew/bin ]; then
  extra_path="/opt/homebrew/bin:$extra_path"
fi
export PATH="$extra_path:${PATH:-/usr/bin:/bin}"

# nvm is common on macOS hosts; devcontainers usually already have Node on PATH.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  if [ -f .nvmrc ]; then
    nvm use --silent >/dev/null 2>&1 || true
  fi
fi

if ! command -v pnpm >/dev/null 2>&1 || ! pnpm -v >/dev/null 2>&1; then
  echo "hook env: pnpm not found or not runnable on PATH" >&2
  exit 127
fi
