# WHY THIS FILE EXISTS: Multi-stage Docker build for the Angular frontend.
# Stage 1 (builder): Node.js — installs deps and builds the Angular app.
# Stage 2 (runtime): nginx:alpine — serves the static files.
# entrypoint.sh injects window.__env from Docker env vars at container start,
# enabling one image to run in multiple environments without rebuild.
# To build: docker build -t webapp-frontend ./frontend
# To run: use docker-compose.yml at the repo root.

# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (layer cache — invalidated only on package.json change)
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci --prefer-offline

# Copy source code
COPY . .

# Build for production
RUN npm run build

# ── Stage 2: Runtime (nginx) ──────────────────────────────────────────────────
FROM nginx:alpine AS runtime

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built Angular app from builder stage
COPY --from=builder /app/dist/webapp/browser /usr/share/nginx/html

# Copy entrypoint script that injects runtime env vars
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:80/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
