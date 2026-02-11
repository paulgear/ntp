.PHONY: build test clean

RELEASE ?= bookworm
VERSION ?= 4.2.8p18
OUTPUT_DIR ?= $(CURDIR)/output-$(RELEASE)
BUILD_CONTAINER ?= deb-build

buildcontainer:
	docker build \
		--build-arg RELEASE=$(RELEASE) \
		-t $(BUILD_CONTAINER) \
		.

build:	buildcontainer
	mkdir -p $(OUTPUT_DIR)
	git archive --format=tar --output=ntp_$(VERSION)+dfsg.orig.tar.gz HEAD
	docker run --rm \
		-v $(CURDIR)/..:/build:ro \
		-v $(OUTPUT_DIR):/output \
		$(BUILD_CONTAINER) \
		bash -c "dpkg-buildpackage -us -uc && find . -name '*.deb' -exec mv {} /output/ \\;"

# To sign: add devscripts package and use debsign, or add -k <keyid> to dpkg-buildpackage

test:	build
	@echo "Installing built package in clean $(RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/output:ro \
		debian:$(RELEASE) \
		bash -c "apt-get update && apt-get install -y /output/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)
