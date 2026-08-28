FROM node:24-alpine

# Create non-root user and group with UID/GID 1001
# This user will run all application-level operations
RUN addgroup --gid 1001 bot-fish-njs && \
    adduser --uid 1001 --ingroup bot-fish-njs --shell /bin/sh --disabled-password bot-fish-njs

# Set the working directory (created as root, will be chowned later)
WORKDIR /usr/src/app

# Install pnpm globally (requires root access to /usr/local)
RUN npm install -g pnpm

# Change ownership of working directory to non-root user
# This is CRITICAL: must be done BEFORE switching to non-root user
RUN chown bot-fish-njs:bot-fish-njs /usr/src/app

# Switch to non-root user for ALL application-level operations
# This ensures preinstall/postinstall scripts run without root privileges
USER bot-fish-njs

# Copy package files with correct ownership
COPY --chown=bot-fish-njs:bot-fish-njs package.json pnpm-lock.yaml ./

# Install dependencies as non-root user (CRITICAL for security)
# Any preinstall/postinstall scripts in packages run as bot-fish-njs, not root
RUN pnpm install --frozen-lockfile

# Copy source code with correct ownership
COPY --chown=bot-fish-njs:bot-fish-njs . .

# Build TypeScript as non-root user
RUN pnpm run build

# Application runs as non-root user
CMD ["pnpm", "start"]
