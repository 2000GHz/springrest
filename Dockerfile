FROM gradle:alpine AS builder
WORKDIR /home/gradle
COPY . .
RUN gradle build 
LABEL org.opencontainers.image.source https://github.com/2000GHz/hello-springrest

FROM amazoncorretto:11-alpine AS runtime
WORKDIR /app
COPY --from=builder /home/gradle/build/libs/rest-service-0.0.1-SNAPSHOT.jar .
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["java -jar rest-service-0.0.1-SNAPSHOT.jar"]