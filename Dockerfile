# Use an official Node.js runtime as a parent image
FROM node:22.15.0-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install pnpm
RUN npm install -g pnpm

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install app dependencies using pnpm
RUN pnpm install --frozen-lockfile

# Bundle app source
COPY . .

# Build the TypeScript project
RUN pnpm run build

# Your app binds to port 3000 so YOU must ensure your environment
# has this port configured correctly. In a typical Docker run, you would
# map this port to a host port using -p <host_port>:3000.
# Since this is a Discord bot, it doesn't listen on a port for incoming HTTP requests.
# EXPOSE 3000 

# Define the command to run your app
CMD [ "pnpm", "start" ] 