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
	cd ..; git archive --output=ntp_$(VERSION)+dfsg.orig.tar.gz HEAD -- ':!debian' ':!docker' ':!.github'
	docker run --rm -ti \
		-v $(CURDIR)/../ntp_$(VERSION)+dfsg.orig.tar.gz:/build/ntp_$(VERSION)+dfsg.orig.tar.gz \
		-v $(CURDIR)/debian:/build/ntp/debian \
		-v $(OUTPUT_DIR):/output \
		$(BUILD_CONTAINER)
# 		 \
# 		bash -c "cd /build/ntp && dpkg-buildpackage -us -uc && find . -name '*.deb' -exec mv {} /output/ \\;"

# To sign: add devscripts package and use debsign, or add -k <keyid> to dpkg-buildpackage

test:	build
	@echo "Installing built package in clean $(RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/output:ro \
		debian:$(RELEASE) \
		bash -c "apt-get update && apt-get install -y /output/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)
