.PHONY: build test clean

DEBIAN_RELEASE ?= bookworm
VERSION ?= 4.2.8p18+dfsg

BUILD_DIR ?= /build
OUTPUT_DIR ?= $(CURDIR)/../packaging/output/$(DEBIAN_RELEASE)
BUILD_CONTAINER ?= deb-build
DOCKERFILE ?= packaging.Dockerfile

buildcontainer:
	docker build \
		-f $(DOCKERFILE) \
		--build-arg BUILD_DIR=$(BUILD_DIR) \
		--build-arg RELEASE=$(DEBIAN_RELEASE) \
		-t $(BUILD_CONTAINER) \
		.

build:	clean buildcontainer
	mkdir -p $(OUTPUT_DIR)/ntp
	git archive --output=$(OUTPUT_DIR)/ntp_$(VERSION).orig.tar.gz HEAD -- ':!debian'
	cp -a debian $(OUTPUT_DIR)/ntp/
	docker run --rm \
		-v $(OUTPUT_DIR):$(BUILD_DIR) \
		-v $(OUTPUT_DIR)/ntp_$(VERSION).orig.tar.gz:$(BUILD_DIR)/ntp_$(VERSION).orig.tar.gz:ro \
		$(BUILD_CONTAINER) \
		bash -c " \
			cd $(BUILD_DIR)/ntp && \
			tar -xf $(BUILD_DIR)/ntp_$(VERSION).orig.tar.gz && \
			dpkg-buildpackage -us -uc \
			"

# To sign: add devscripts package and use debsign, or add -k <keyid> to dpkg-buildpackage

test:
	@echo "Installing built package in clean $(DEBIAN_RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/output:ro \
		debian:$(DEBIAN_RELEASE) \
		bash -c "apt-get update && apt-get install -y /output/*.deb && dpkg -l | grep ntp"

clean:
	sudo rm -rf $(OUTPUT_DIR)
