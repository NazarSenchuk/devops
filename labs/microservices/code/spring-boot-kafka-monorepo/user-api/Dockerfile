# Build stage
FROM gradle:8.5-jdk17-alpine AS builder
WORKDIR /app

# Copy gradle files first for better caching
COPY gradle ./gradle
COPY gradlew .
COPY gradlew.bat .
COPY build.gradle .
COPY settings.gradle .

# Make gradlew executable
RUN chmod +x gradlew

# Copy source code
COPY src ./src

# Build the application
RUN ./gradlew clean build -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy ONLY the main executable JAR (exclude -plain.jar)
COPY --from=builder /app/build/libs/user-api-0.0.1-SNAPSHOT.jar /app/app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
