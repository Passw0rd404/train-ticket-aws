ARG JAVA_RUNTIME_IMAGE=ghcr.io/passw0rd404/train-ticket-java-runtime:latest
FROM ${JAVA_RUNTIME_IMAGE}

ENV OTEL_SERVICE_NAME=ts-gateway-service

COPY --chmod=0644 target/ts-gateway-service-1.0.jar /app/
USER 10001:10001

CMD ["java", "-Xmx1024m",  "-jar", "/app/ts-gateway-service-1.0.jar"]

EXPOSE 18888 
