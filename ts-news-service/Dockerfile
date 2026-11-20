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
