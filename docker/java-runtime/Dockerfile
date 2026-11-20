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
