# ---------- Stage 1: install dependencies ----------
# Kept separate so the final image never carries npm's cache or build tooling.
FROM node:20-alpine AS deps

WORKDIR /app

# Copy manifests first. Docker caches this layer, so dependencies are only
# reinstalled when package.json changes - not on every source edit.
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force


# ---------- Stage 2: runtime ----------
FROM node:20-alpine AS runtime

# wget is used by the HEALTHCHECK below.
RUN apk add --no-cache wget

WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000

COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY server.js ./
COPY public ./public

# The node image ships an unprivileged 'node' user. Running as root inside a
# container is a common finding in security reviews, so drop to it.
USER node

EXPOSE 3000

# Docker marks the container healthy/unhealthy based on this command's exit
# code. Visible in `docker ps` under STATUS.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/healthz || exit 1

CMD ["node", "server.js"]
