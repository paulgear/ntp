.PHONY: build test clean

DEBIAN_RELEASE ?= bookworm
VERSION ?= 4.2.8p18

BUILD_DIR ?= /build
ORIG_DIR ?= $(CURDIR)/packaging/output
OUTPUT_DIR ?= $(CURDIR)/packaging/output/$(DEBIAN_RELEASE)
BUILD_CONTAINER ?= deb-build
DOCKERFILE ?= packaging.Dockerfile

buildcontainer:
	docker build \
		-f $(DOCKERFILE) \
		--build-arg BUILD_DIR=$(BUILD_DIR) \
		--build-arg RELEASE=$(DEBIAN_RELEASE) \
		-t $(BUILD_CONTAINER) \
		.

build:	buildcontainer
	mkdir -p $(ORIG_DIR) $(OUTPUT_DIR)
	git archive --output=$(ORIG_DIR)/ntp_$(VERSION)+dfsg.orig.tar.gz HEAD -- ':!debian' ':!.github' ':!.opencode'
	docker run --rm -ti \
		-v $(OUTPUT_DIR):$(BUILD_DIR) \
		-v $(CURDIR):$(BUILD_DIR)/ntp \
		-v $(ORIG_DIR)/ntp_$(VERSION)+dfsg.orig.tar.gz:$(BUILD_DIR)/ntp_$(VERSION)+dfsg.orig.tar.gz:ro \
		$(BUILD_CONTAINER) \
		bash -c "cd $(BUILD_DIR)/ntp && dpkg-buildpackage -us -uc"

# To sign: add devscripts package and use debsign, or add -k <keyid> to dpkg-buildpackage

test:	build
	@echo "Installing built package in clean $(DEBIAN_RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/output:ro \
		debian:$(DEBIAN_RELEASE) \
		bash -c "apt-get update && apt-get install -y /output/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)
