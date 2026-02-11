ARG RELEASE=bookworm
FROM debian:${RELEASE}

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git

# VOLUME /build
# VOLUME /output

WORKDIR /tmp
COPY debian/control debian/
RUN apt-get build-dep -y .
