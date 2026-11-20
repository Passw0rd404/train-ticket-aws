ARG JAVA_RUNTIME_IMAGE=ghcr.io/passw0rd404/train-ticket-java-runtime:latest
FROM ${JAVA_RUNTIME_IMAGE}

ENV OTEL_SERVICE_NAME=ts-order-service

LABEL maintainer="TrainTicket F1 Fault Injection"

WORKDIR /app

COPY --chmod=0644 target/ts-order-service-1.0.jar app.jar

EXPOSE 12031

USER 10001:10001

ENTRYPOINT ["java", "-jar", "app.jar"]
