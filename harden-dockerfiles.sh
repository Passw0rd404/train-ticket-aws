#!/usr/bin/env bash
# Hardens every Dockerfile except ts-ui-dashboard.
# Run it from the repository root (the folder that contains docker/ and ts-order-service/).
set -euo pipefail

if [ ! -d docker/java-runtime ] || [ ! -d ts-order-service ]; then
  echo "Run this from the repository root." >&2
  exit 1
fi

# Java runtime base image (non-root, timezone, OpenTelemetry agent)
cat > docker/java-runtime/Dockerfile <<'EOF'
FROM eclipse-temurin:8-jre

# Links the published package to this repository, so the repo's workflows can pull it
LABEL org.opencontainers.image.source="https://github.com/Passw0rd404/train-ticket-aws" \
      org.opencontainers.image.description="Java 8 runtime with the OpenTelemetry agent, runs as a non-root user"

# The timezone every Java service used to set in its own Dockerfile
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo 'Asia/Shanghai' > /etc/timezone

# Non-root user with a fixed numeric ID, so Kubernetes can verify runAsNonRoot.
# /app belongs to it, so a service can still write files there.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid 10001 --home-dir /app --no-create-home --shell /usr/sbin/nologin app \
 && mkdir -p /app \
 && chown app:app /app

# --chmod is needed: a file fetched by ADD is readable by root only (0600) by default,
# and the agent would fail to load for the app user.
ADD --chmod=0644 --checksum=sha256:bbf83c151b6400709e2f225bdd07a04f839d9d13b8b93464241333fd25d3e3ba \
    https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.31.1/opentelemetry-javaagent.jar \
    /opt/otel/opentelemetry-javaagent.jar

ENV JAVA_TOOL_OPTIONS="-javaagent:/opt/otel/opentelemetry-javaagent.jar" \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none

WORKDIR /app
USER 10001:10001
EOF

# Python / Tornado
cat > ts-voucher-service/Dockerfile <<'EOF'
FROM python:3.12-slim-bookworm

# Slim images do not guarantee tzdata, so install it before setting the timezone
RUN apt-get update \
 && apt-get install -y --no-install-recommends tzdata \
 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && echo 'Asia/Shanghai' > /etc/timezone \
 && rm -rf /var/lib/apt/lists/*

# Non-root user with a fixed numeric ID, so Kubernetes can verify runAsNonRoot
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py feature_flag_service.py ./

ENV PYTHONDONTWRITEBYTECODE=1 \
    OTEL_SERVICE_NAME=ts-voucher-service \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none

USER 10001:10001

CMD [ "opentelemetry-instrument", "python", "-u", "server.py" ]

EXPOSE 16101
EOF

# Python / Flask
cat > ts-avatar-service/Dockerfile <<'EOF'
FROM python:3.9-bookworm

RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

# dlib is compiled from source, so the build tools of this full image are needed.
# (--no-install-recommends is left out on purpose so the toolchain stays the same.)
RUN apt-get update \
 && apt-get install -y cmake libgl1 \
 && rm -rf /var/lib/apt/lists/*

# Pin to an older version that works with dlib 19.24.2
ENV CMAKE_POLICY_VERSION_MINIMUM=3.5
ENV PYTHONUNBUFFERED=TRUE

# Non-root user with a fixed numeric ID, so Kubernetes can verify runAsNonRoot
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

ENV OTEL_SERVICE_NAME=ts-avatar-service \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none

# The service saves uploaded and cropped images under ./received and ./images
RUN chown -R app:app /app/received /app/images

USER 10001:10001

CMD ["opentelemetry-instrument", "gunicorn", "-w", "4", "-b", "0.0.0.0:17001", "app:app"]

EXPOSE 17001
EOF

# Node
cat > ts-ticket-office-service/Dockerfile <<'EOF'
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
EOF

# Go
cat > ts-news-service/Dockerfile <<'EOF'
FROM --platform=$BUILDPLATFORM golang:1.23-bookworm AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY ./src/main ./

ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o app .

FROM alpine:3.22
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

# Non-root user with a fixed numeric ID, so Kubernetes can verify runAsNonRoot
RUN addgroup -S -g 10001 app && \
    adduser -S -u 10001 -G app -H -s /sbin/nologin app

WORKDIR /app
COPY --from=builder /app/app .
ENV OTEL_SERVICE_NAME=ts-news-service \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc

USER 10001:10001

CMD ["./app"]
EXPOSE 12862
EOF

# The 41 Java services: our own base image, no timezone line, COPY with fixed permissions,
# and a non-root user. Files that already have the USER line are skipped, so it is safe to re-run.
for d in ts-*/; do
  d=${d%/}
  [ -f "$d/pom.xml" ] && [ -f "$d/Dockerfile" ] || continue
  grep -q '^USER 10001:10001$' "$d/Dockerfile" && continue
  sed -i -E \
    -e 's|^ARG JAVA_RUNTIME_IMAGE=.*|ARG JAVA_RUNTIME_IMAGE=ghcr.io/passw0rd404/train-ticket-java-runtime:latest|' \
    -e '/^RUN \/bin\/cp \/usr\/share\/zoneinfo\/Asia\/Shanghai/d' \
    -e 's|^ADD \./target/([^ ]+\.jar) /app/[[:space:]]*$|COPY --chmod=0644 target/\1 /app/|' \
    -e 's|^COPY target/([^ ]+\.jar) app\.jar[[:space:]]*$|COPY --chmod=0644 target/\1 app.jar|' \
    -e '0,/^(CMD|ENTRYPOINT)/s//USER 10001:10001\n\n&/' \
    "$d/Dockerfile"
  sed -i '/^$/N;/^\n$/D' "$d/Dockerfile"
done

echo "Done. Review the changes with: git diff --stat"
