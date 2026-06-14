#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVMRC="$ROOT/.nvmrc"
DOCKERFILE="$ROOT/Dockerfile"
COMPOSE="$ROOT/docker-compose.yml"

expected="$(tr -d '[:space:]' < "$NVMRC")"

docker_version="$(grep -E '^ARG NODE_VERSION=' "$DOCKERFILE" | head -1 | cut -d= -f2 | tr -d '[:space:]')"
devcontainer_image="$(grep -E 'javascript-node:1-[0-9]+' "$COMPOSE" | head -1 | sed -E 's/.*javascript-node:1-([0-9]+)-.*/\1/')"

if [[ "$docker_version" != "$expected" ]]; then
  echo "Dockerfile NODE_VERSION ($docker_version) does not match .nvmrc ($expected)" >&2
  exit 1
fi

if [[ -z "$devcontainer_image" || "$devcontainer_image" != "$expected" ]]; then
  echo "devcontainer Node major ($devcontainer_image) does not match .nvmrc ($expected)" >&2
  exit 1
fi

echo "Node version parity OK: $expected"
