ARG RELEASE=bookworm
FROM debian:${RELEASE}

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        gbp \
        git

WORKDIR /tmp
COPY debian/control debian/
RUN apt-get build-dep -y .

VOLUME /build
VOLUME /output
WORKDIR /build
