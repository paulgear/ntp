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
			apt-get install -y build-essential && \
			cd /build && \
			apt-get build-dep -y . && \
			dpkg-buildpackage -us -uc && \
			find . -name '*.deb' -exec mv {} /output/ \\;"

test:
	$(MAKE) build RELEASE=$(RELEASE)
	@echo "Installing built package in clean $(RELEASE) container..."
	docker run --rm \
		-v $(OUTPUT_DIR):/host-build:ro \
		debian:$(RELEASE) \
		bash -c "apt-get update && apt-get install -y /host-build/*.deb && dpkg -l | grep ntp"

clean:
	rm -rf $(OUTPUT_DIR)
