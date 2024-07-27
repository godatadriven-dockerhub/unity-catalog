# Use Debian Bullseye Slim as the base image.
FROM debian:bullseye-slim

# Set the working directory
WORKDIR /app

# Define UC_VERSION
ARG UC_VERSION

# Limit the memory usage of the sbt process to 2GB
ENV SBT_OPTS="-Xmx2G"

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    unzip \
    wget \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/unitycatalog/unitycatalog/archive/refs/tags/v${UC_VERSION}.zip \
    && unzip v${UC_VERSION}.zip \
    && mv unitycatalog-${UC_VERSION} unitycatalog \
    && rm v${UC_VERSION}.zip

# Download and install sbt
RUN curl -L -o sbt-1.9.8.tgz https://github.com/sbt/sbt/releases/download/v1.9.8/sbt-1.9.8.tgz && \
    tar -xvzf sbt-1.9.8.tgz && \
    mv sbt /usr/local && \
    rm sbt-1.9.8.tgz

ENV PATH="/usr/local/sbt/bin:${PATH}"

WORKDIR /app/unitycatalog

# Compile unity catalog and remove useless target directory
RUN sbt clean compile package && \
    rm -rf target

# Build the final image with the compiled unity catalog
FROM openjdk:11-jre-slim-bullseye

COPY --from=0 /app/unitycatalog/ /app/unitycatalog/
COPY --from=0 /root/.cache/coursier/v1/https/ /root/.cache/coursier/v1/https/

WORKDIR /app/unitycatalog

# Listen to port 8080
EXPOSE 8080

# Run the server
CMD ["bin/start-uc-server"]
