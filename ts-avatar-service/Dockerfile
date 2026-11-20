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
