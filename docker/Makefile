.PHONY: build test clean

RELEASE ?= bookworm
OUTPUT_DIR ?= $(CURDIR)/build-results

build:
	mkdir -p $(OUTPUT_DIR)
	docker build \
		--build-arg RELEASE=$(RELEASE) \
		-f $(CURDIR)/Dockerfile.build \
		-t ntp-builder-$(RELEASE) \
		$(CURDIR)
	docker run --rm \
		-v $(OUTPUT_DIR):/output \
		ntp-builder-$(RELEASE) \
		bash -c "find /build -name '*.deb' -exec cp {} /output/ \\;"
	@echo "Build complete. .deb files in $(OUTPUT_DIR)/"

test:
	$(MAKE) build RELEASE=$(RELEASE)
	@echo "Installing built package in clean $(RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/host-build:ro \
		debian:$(RELEASE) \
		bash -c "apt-get update && apt-get install -y /host-build/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)
	docker rmi -f ntp-builder-$(RELEASE) 2>/dev/null || true
