# Use Amazon Corretto 11 as the base image.
FROM amazoncorretto:17-alpine-jdk
# Set the working directory
WORKDIR /app

# Define UC_VERSION
ENV UC_VERSION=v0.1.0

# Limit the memory usage of the sbt process to 2GB
ENV SBT_OPTS="-Xmx2G"

# Install git, fetch unity catalog, and remove git
RUN apk add --no-cache git curl bash && \
    git clone --depth 1 --branch ${UC_VERSION} https://github.com/unitycatalog/unitycatalog.git && \
    apk del git

# Download and install sbt
RUN curl -L -o sbt-1.9.8.tgz https://github.com/sbt/sbt/releases/download/v1.9.8/sbt-1.9.8.tgz && \
    tar -xvzf sbt-1.9.8.tgz && \
    mv sbt /usr/local && \
    rm sbt-1.9.8.tgz

# Add sbt to PATH
ENV PATH="/usr/local/sbt/bin:${PATH}"

# Navigate to the project directory
WORKDIR /app/unitycatalog

# Compile unity catalog
RUN sbt clean compile package

# Listen to port 8080
EXPOSE 8080

# Run the server
CMD ["bin/start-uc-server"]