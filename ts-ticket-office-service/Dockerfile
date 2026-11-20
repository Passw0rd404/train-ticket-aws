FROM node:22-bookworm-slim

# Slim images do not guarantee tzdata, so install it before setting the timezone
RUN apt-get update \
 && apt-get install -y --no-install-recommends tzdata \
 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo 'Asia/Shanghai' > /etc/timezone \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY public ./public
COPY bin ./bin
COPY app.js ./

ENV NODE_OPTIONS="--require @opentelemetry/auto-instrumentations-node/register" \
    OTEL_SERVICE_NAME=ts-ticket-office-service \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none \
    OTEL_NODE_ENABLED_INSTRUMENTATIONS=http,express,mysql \
    OTEL_NODE_RESOURCE_DETECTORS=env,process

# The official image already ships a non-root "node" user (UID 1000). The code stays
# root-owned, so the app can read it but not change it.
USER 1000:1000

CMD [ "node", "bin/www" ]

EXPOSE 16108
