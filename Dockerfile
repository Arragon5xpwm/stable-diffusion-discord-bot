# syntax=docker/dockerfile:1
FROM node:18-bullseye AS builder
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends git && apt-get clean
WORKDIR /build
RUN GIT_NO_COLOR=1 git clone --separate-git-dir=$(mktemp -u) --depth 1 https://github.com/ausbitbank/stable-diffusion-discord-bot .
# Build dependencies
RUN NO_COLOR=1 npm install --omit=dev

FROM node:18-bullseye
# Create app directory
WORKDIR /bot
# Install app dependencies
COPY --from=builder /build/package*.json ./
COPY --from=builder /build/node_modules/ ./node_modules
COPY --from=builder /build/txt/ ./txt
COPY --from=builder /build/index.js ./
COPY --from=builder /build/config.example/ ./config
RUN echo -n "{}" >./config/dbNSFWChannels.json
RUN echo -n "{}" >./config/dbGalleryChannels.json

VOLUME "/InvokeAI/outputs"

ENTRYPOINT ["node", "-r", "dotenv/config", "index.js"]
