ARG RELEASE=bookworm
FROM debian:${RELEASE}

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git

WORKDIR /tmp
COPY debian/control debian/
RUN apt-get build-dep -y .

ARG BUILD_DIR
VOLUME ${BUILD_DIR}
VOLUME /output
WORKDIR ${BUILD_DIR}
