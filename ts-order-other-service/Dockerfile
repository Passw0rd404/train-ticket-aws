ARG JAVA_RUNTIME_IMAGE=ghcr.io/passw0rd404/train-ticket-java-runtime:latest
FROM ${JAVA_RUNTIME_IMAGE}

ENV OTEL_SERVICE_NAME=ts-order-other-service

COPY --chmod=0644 target/ts-order-other-service-1.0.jar /app/
USER 10001:10001

CMD ["java", "-Xmx200m",  "-jar", "/app/ts-order-other-service-1.0.jar"]
#CMD java $JAVA_OPTIONS -jar /app/ts-order-other-service-1.0.jar
EXPOSE 12032
