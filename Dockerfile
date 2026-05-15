FROM node:22.15.0-slim

# Create non-root user and group with UID/GID 1001
# This user will run all application-level operations
RUN groupadd --gid 1001 bot-njs && \
    useradd --uid 1001 --gid bot-njs --shell /bin/bash --create-home bot-njs

# Set the working directory (created as root, will be chowned later)
WORKDIR /usr/src/app

# Install pnpm globally (requires root access to /usr/local)
RUN npm install -g pnpm

# Change ownership of working directory to non-root user
# This is CRITICAL: must be done BEFORE switching to non-root user
RUN chown bot-njs:bot-njs /usr/src/app

# Switch to non-root user for ALL application-level operations
# This ensures preinstall/postinstall scripts run without root privileges
USER bot-njs

# Copy package files with correct ownership
COPY --chown=bot-njs:bot-njs package.json pnpm-lock.yaml ./

# Install dependencies as non-root user (CRITICAL for security)
# Any preinstall/postinstall scripts in packages run as bot-njs, not root
RUN pnpm install --frozen-lockfile

# Copy source code with correct ownership
COPY --chown=bot-njs:bot-njs . .

# Build TypeScript as non-root user
RUN pnpm run build

# Application runs as non-root user
CMD ["pnpm", "start"]
