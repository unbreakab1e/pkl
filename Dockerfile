# Multi-stage build for Pkl
FROM openjdk:21-jdk AS builder

# Set working directory
WORKDIR /app

# Copy gradle wrapper and configuration files
COPY gradlew .
COPY gradlew.bat .
COPY gradle/ gradle/
COPY settings.gradle.kts .
COPY build.gradle.kts .
COPY gradle.properties .

# Copy all project source files
COPY . .

# Make gradlew executable
RUN chmod +x gradlew

# Build the project
RUN ./gradlew build -x test

# Runtime stage
FROM openjdk:21-jre-slim

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy built artifacts from builder stage
COPY --from=builder /app/pkl-cli/build/libs/*.jar pkl-cli.jar

# Create non-root user
RUN useradd -r -s /bin/false pkl

# Change ownership and switch to non-root user
RUN chown -R pkl:pkl /app
USER pkl

# Expose default port (if applicable)
EXPOSE 8080

# Default command
ENTRYPOINT ["java", "-jar", "pkl-cli.jar"]
CMD ["--help"]