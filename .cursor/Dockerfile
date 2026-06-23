ARG NODE_VERSION=22
ARG PNPM_VERSION=10.18.3

FROM node:${NODE_VERSION}-bookworm-slim

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN apt-get update \
  && apt-get install -y --no-install-recommends git sudo curl ca-certificates gnupg gpg-agent \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable pnpm && corepack prepare pnpm@${PNPM_VERSION} --activate
