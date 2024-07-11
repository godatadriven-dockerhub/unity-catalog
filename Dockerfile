# Use Amazon Corretto 11 as the base image.
FROM amazoncorretto:11
# Set the working directory
WORKDIR /app

# Define UC_VERSION
ENV UC_VERSION=v0.1.0

# Limit the memory usage of the sbt process to 2GB
ENV SBT_OPTS="-Xmx2G"

# Fetch unity catalog and install sbt
RUN yum install -y git && \
    git clone --depth 1 --branch ${UC_VERSION} https://github.com/unitycatalog/unitycatalog.git && \
    yum remove -y git && \
    curl -L -o sbt-1.9.8.rpm https://repo.scala-sbt.org/scalasbt/rpm/sbt-1.9.8.rpm && \
    rpm -ivh sbt-1.9.8.rpm && \
    rm sbt-1.9.8.rpm

# Navigate to the project directory
WORKDIR /app/unitycatalog

# Compile unity catalog
RUN sbt clean compile package

# Listen to port 8080
EXPOSE 8080

# Run the server
CMD ["bin/start-uc-server"]