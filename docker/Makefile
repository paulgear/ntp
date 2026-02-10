.PHONY: build test clean

RELEASE ?= bookworm
OUTPUT_DIR ?= $(CURDIR)/build-results

build:
	mkdir -p $(OUTPUT_DIR)
	docker run --rm \
		-v $(CURDIR)/..:/build:ro \
		-v $(OUTPUT_DIR):/output \
		debian:$(RELEASE) \
		bash -c "\
			apt-get update && \
			apt-get install -y \
				build-essential \
				autogen \
				debhelper \
				dh-apparmor \
				libcap2-dev \
				libedit-dev \
				libevent-dev \
				libopts25-dev \
				libssl-dev \
				pkg-config \
				pps-tools \
				&& rm -rf /var/lib/apt/lists/* && \
			cd /build && \
			dpkg-buildpackage -us -uc && \
			find /build -name '*.deb' -exec cp {} /output/ \\;"

test:
	$(MAKE) build RELEASE=$(RELEASE)
	@echo "Installing built package in clean $(RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/host-build:ro \
		debian:$(RELEASE) \
		bash -c "apt-get update && apt-get install -y /host-build/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)