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
