# syntax=docker/dockerfile:1
FROM node:18-bullseye AS builder
ENV NO_COLOR=true
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends git && apt-get clean
WORKDIR /build
RUN git clone --separate-git-dir=$(mktemp -u) --depth 1 https://github.com/ausbitbank/stable-diffusion-discord-bot .
# Build dependencies
RUN npm install --omit=dev

FROM node:18-bullseye
# Create app directory
WORKDIR /bot
# Install app dependencies
COPY --from=builder /build/package*.json ./
COPY --from=builder /build/node_modules/ ./node_modules
COPY --from=builder /build/txt/ ./txt
COPY --from=builder /build/index.js ./
COPY --from=builder /build/dbGalleryChannels.json.example dbGalleryChannels.json
COPY --from=builder /build/dbPayments.json.example dbPayments.json
COPY --from=builder /build/dbQueue.json.example dbQueue.json
COPY --from=builder /build/dbSchedule.json.example dbSchedule.json
COPY --from=builder /build/dbUsers.json.example dbUsers.json
COPY --from=builder /build/dbNSFWChannels.json.example dbNSFWChannels.json

VOLUME "/InvokeAI/outputs"

ENTRYPOINT ["node", "-r", "dotenv/config", "index.js"]
