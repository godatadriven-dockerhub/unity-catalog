ARG ALPINE_VERSION="3.20"
ARG SBT_RESOLVER="https://oss.sonatype.org/content/repositories/releases/"
ARG sbt_args="-J-Xmx4G -Dsbt.resolver=${SBT_RESOLVER}"
ARG UC_VERSION="0.2.0"

# Build stage, using Amazon Corretto jdk 17 on alpine with arm64 support
FROM amazoncorretto:17-alpine${ALPINE_VERSION}-jdk AS base
ARG sbt_args
ARG SBT_RESOLVER
ARG UC_VERSION

# Set the working directory
WORKDIR /app

# Define UC_VERSION
ARG UC_VERSION

RUN apk update && apk add --no-cache \
    curl \
    bash

RUN wget https://github.com/unitycatalog/unitycatalog/archive/refs/tags/v${UC_VERSION}.zip \
    && unzip v${UC_VERSION}.zip \
    && mv unitycatalog-${UC_VERSION} unitycatalog \
    && rm v${UC_VERSION}.zip

# Download and install sbt
RUN curl -L -o sbt-1.9.9.tgz https://github.com/sbt/sbt/releases/download/v1.9.9/sbt-1.9.9.tgz && \
    tar -xvzf sbt-1.9.9.tgz && \
    mv sbt /usr/local && \
    rm sbt-1.9.9.tgz

ENV PATH="/usr/local/sbt/bin:${PATH}"

WORKDIR /app/unitycatalog

# Compile unity catalog and remove useless target directory
RUN sbt ${sbt_args} clean compile package && \
    rm -rf target

# Build the final image with the compiled unity catalog
FROM alpine:${ALPINE_VERSION} AS runtime


ARG JAVA_HOME="/usr/lib/jvm/default-jvm"
ARG HOME

RUN apk update && apk add --no-cache bash

# Copy Java from base
COPY --from=base $JAVA_HOME $JAVA_HOME

ENV HOME=$HOME \
    JAVA_HOME=$JAVA_HOME \
    PATH="${JAVA_HOME}/bin:${PATH}"

COPY --from=base /app/unitycatalog/ /app/unitycatalog/
COPY --from=base /root/.cache/ /root/.cache/

WORKDIR /app/unitycatalog

# Listen to port 8080
EXPOSE 8080

# Run the server
CMD ["bin/start-uc-server"]
