.PHONY: build test clean

DEBIAN_RELEASE ?= bookworm
VERSION ?= $(shell dpkg-parsechangelog -S Version | sed -e 's/^[0-9]://; s/-[0-9]*$$//;')

BUILD_DIR ?= /build
OUTPUT_DIR ?= $(CURDIR)/../packaging/output/$(DEBIAN_RELEASE)
BUILD_CONTAINER ?= deb-build
DOCKERFILE ?= packaging.Dockerfile

what:
	@echo "What would you like to make today?"
	@echo "Options: buildcontainer build test clean all"

all:	clean buildcontainer build test

buildcontainer:
	docker build \
		-f $(DOCKERFILE) \
		--build-arg BUILD_DIR=$(BUILD_DIR) \
		--build-arg RELEASE=$(DEBIAN_RELEASE) \
		-t $(BUILD_CONTAINER):$(DEBIAN_RELEASE) \
		.

build:	buildcontainer
	mkdir -p $(OUTPUT_DIR)/ntp
	git archive --output=$(OUTPUT_DIR)/ntp_$(VERSION).orig.tar.gz HEAD -- ':!debian'
	cp -a debian $(OUTPUT_DIR)/ntp/
	docker run --rm \
		-v $(OUTPUT_DIR):$(BUILD_DIR) \
		-v $(OUTPUT_DIR)/ntp_$(VERSION).orig.tar.gz:$(BUILD_DIR)/ntp_$(VERSION).orig.tar.gz:ro \
		$(BUILD_CONTAINER):$(DEBIAN_RELEASE) \
		bash -c " \
			cd $(BUILD_DIR)/ntp && \
			tar -xf $(BUILD_DIR)/ntp_$(VERSION).orig.tar.gz && \
			DEB_BUILD_OPTIONS=noautodbgsym dpkg-buildpackage -us -uc \
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

dockerclean:
	docker image rm $(BUILD_CONTAINER):$(DEBIAN_RELEASE)
