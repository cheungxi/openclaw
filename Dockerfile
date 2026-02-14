FROM node:22-bookworm

# Detect architecture and set build environment
ARG TARGETARCH
RUN echo "Building for architecture: ${TARGETARCH:-$(dpkg --print-architecture)}"

# Install Bun (required for build scripts) - skip on LoongArch if not supported
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" != "loong64" ]; then \
      curl -fsSL https://bun.sh/install | bash && \
      export PATH="/root/.bun/bin:${PATH}"; \
    else \
      echo "Bun not available on LoongArch, will use Node for all operations"; \
    fi
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# Install build dependencies needed for native modules on LoongArch
ARG OPENCLAW_DOCKER_APT_PACKAGES=""
RUN ARCH=$(dpkg --print-architecture) && \
    EXTRA_PACKAGES="" && \
    if [ "$ARCH" = "loong64" ]; then \
      EXTRA_PACKAGES="python3 make g++ pkg-config"; \
    fi && \
    if [ -n "$OPENCLAW_DOCKER_APT_PACKAGES" ] || [ -n "$EXTRA_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $OPENCLAW_DOCKER_APT_PACKAGES $EXTRA_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts

# Install dependencies with special handling for LoongArch
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "loong64" ]; then \
      echo "Installing on LoongArch - some optional native modules may be built from source"; \
      pnpm install --frozen-lockfile --no-optional || pnpm install --frozen-lockfile; \
    else \
      pnpm install --frozen-lockfile; \
    fi

COPY . .
RUN pnpm build
# Force pnpm for UI build (Bun may fail on ARM/Synology/LoongArch architectures)
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

ENV NODE_ENV=production

# Allow non-root user to write temp files during runtime/tests.
RUN chown -R node:node /app

# Security hardening: Run as non-root user
# The node:22-bookworm image includes a 'node' user (uid 1000)
# This reduces the attack surface by preventing container escape via root privileges
USER node

# Start gateway server with default config.
# Binds to loopback (127.0.0.1) by default for security.
#
# For container platforms requiring external health checks:
#   1. Set OPENCLAW_GATEWAY_TOKEN or OPENCLAW_GATEWAY_PASSWORD env var
#   2. Override CMD: ["node","openclaw.mjs","gateway","--allow-unconfigured","--bind","lan"]
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
