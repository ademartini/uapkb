#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVMRC="$ROOT/.nvmrc"
PACKAGE_JSON="$ROOT/package.json"
DOCKERFILE="$ROOT/Dockerfile"
CURSOR_DOCKERFILE="$ROOT/.cursor/Dockerfile"
DEVCONTAINER="$ROOT/.devcontainer/devcontainer.json"

expected="$(tr -d '[:space:]' < "$NVMRC")"

docker_version="$(grep -E '^ARG NODE_VERSION=' "$DOCKERFILE" | head -1 | cut -d= -f2 | tr -d '[:space:]')"
cursor_docker_version="$(grep -E '^ARG NODE_VERSION=' "$CURSOR_DOCKERFILE" | head -1 | cut -d= -f2 | tr -d '[:space:]')"
devcontainer_image="$(grep -E 'javascript-node:1-[0-9]+' "$DEVCONTAINER" | head -1 | sed -E 's/.*javascript-node:1-([0-9]+)-.*/\1/')"
package_node_engine="$(node -p "require('$PACKAGE_JSON').engines.node" | sed -E 's/^([0-9]+).*/\1/')"

if [[ "$docker_version" != "$expected" ]]; then
  echo "Dockerfile NODE_VERSION ($docker_version) does not match .nvmrc ($expected)" >&2
  exit 1
fi

if [[ "$package_node_engine" != "$expected" ]]; then
  echo "package.json engines.node ($package_node_engine) does not match .nvmrc ($expected)" >&2
  exit 1
fi

if [[ -z "$devcontainer_image" || "$devcontainer_image" != "$expected" ]]; then
  echo "devcontainer Node major ($devcontainer_image) does not match .nvmrc ($expected)" >&2
  exit 1
fi

if [[ "$cursor_docker_version" != "$expected" ]]; then
  echo "Cursor Cloud Dockerfile NODE_VERSION ($cursor_docker_version) does not match .nvmrc ($expected)" >&2
  exit 1
fi

echo "Node version parity OK: $expected"
