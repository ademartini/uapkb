# Shared PATH setup for Cursor hooks (non-login shell; profile/nvm often not loaded).
repo_root="${CURSOR_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$repo_root"

# Baseline for stripped hook shells: host macOS and devcontainer Linux both use these.
extra_path="/usr/local/bin:$HOME/.local/bin:$HOME/.cursor/bin"
if [ -d /opt/homebrew/bin ]; then
  extra_path="/opt/homebrew/bin:$extra_path"
fi
export PATH="$extra_path:${PATH:-/usr/bin:/bin}"

# nvm is common on macOS hosts and not used in the devcontainer base image.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
nvm_pinned=false
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  if [ -f .nvmrc ] && nvm use --silent >/dev/null 2>&1; then
    nvm_pinned=true
  fi
fi

if ! command -v pnpm >/dev/null 2>&1 || ! pnpm -v >/dev/null 2>&1; then
  pnpm_bin=""
  # Last resort: newest nvm Node with a working pnpm (skip when .nvmrc is pinned).
  if [ "$nvm_pinned" = false ] && [ -d "$NVM_DIR/versions/node" ]; then
    while IFS= read -r bin_dir; do
      if [ -x "$bin_dir/pnpm" ] && "$bin_dir/pnpm" -v >/dev/null 2>&1; then
        pnpm_bin="$bin_dir"
        break
      fi
    done < <(ls -1d "$NVM_DIR"/versions/node/v*/bin 2>/dev/null | sort -Vr)
  fi
  if [ -n "$pnpm_bin" ]; then
    PATH="$pnpm_bin:$PATH"
    export PATH
  fi
fi

if ! command -v pnpm >/dev/null 2>&1 || ! pnpm -v >/dev/null 2>&1; then
  echo "hook env: pnpm not found or not runnable on PATH" >&2
  exit 127
fi
