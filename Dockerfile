# This Dockerfile is created following the security practices in this snyk article:
# -> https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
# 
# and the structure of the official docker example from Vercel:
# -> https://github.com/vercel/next.js/tree/canary/examples/with-docker

FROM node:18-alpine AS base

# Build Image #1
# -> Install dumb-init
# -> Install node modules

FROM base AS deps

RUN apk update && apk add --no-cache libc6-compat dumb-init unzip curl

RUN mkdir -p /tmp/rclone
WORKDIR /tmp/rclone

RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip && \
    cd rclone-*-linux-amd64 && \
    cp rclone /usr/bin/

WORKDIR /app

RUN npm i -g pnpm

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile --ignore-scripts

# Build Image #2
# -> Copy node modules from "deps" image
# -> Build the app

FROM base AS builder

WORKDIR /app

RUN npm i -g pnpm

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

RUN pnpm build

# Production Image
# -> Copy only necessary dependencies from build images
# -> Use "nextjs" user (no root perms)
# -> Start app with "dumb-init" (https://github.com/Yelp/dumb-init)

FROM base AS runner

ENV PORT 8080
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN npm i -g pnpm

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=deps /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=deps --chown=nextjs:nodejs --chmod=755 /usr/bin/rclone /usr/bin/rclone

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 8080

CMD ["dumb-init", "node", "server.js"]