ARG ALPINE_VERSION="3.20"
ARG SBT_RESOLVER="https://oss.sonatype.org/content/repositories/releases/"
ARG sbt_args="-J-Xmx4G -Dsbt.resolver=${SBT_RESOLVER} -Djava.net.preferIPv4Stack=true"
ARG UC_VERSION="0.2.0"
ARG HOME="/app/unitycatalog"

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

# Compile unity catalog
RUN sbt ${sbt_args} clean compile package

# Build the final image with the compiled unity catalog
FROM alpine:${ALPINE_VERSION} AS runtime


ARG JAVA_HOME="/usr/lib/jvm/default-jvm"
ARG USER="unitycatalog"
ARG HOME
ENV HOME=$HOME


RUN apk update && apk add --no-cache bash

# Copy Java from base
COPY --from=base $JAVA_HOME $JAVA_HOME

ENV HOME=$HOME \
    JAVA_HOME=$JAVA_HOME \
    PATH="${JAVA_HOME}/bin:${PATH}"

COPY --from=base $HOME $HOME
COPY --from=base /root/.cache/ /root/.cache/

WORKDIR $HOME



# Create a user and group for the unity catalog
RUN <<EOF
addgroup -S $USER
adduser -S -G $USER $USER
chmod -R 550 $HOME
mkdir -p $HOME/etc/
chmod -R 770 $HOME/etc/
chown -R $USER:$USER $HOME
EOF

# Listen to port 8080
EXPOSE 8080

# Run the server
CMD ["bin/start-uc-server"]
