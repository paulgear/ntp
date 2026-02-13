# NTP Debian Package Build System

Instructions for creating Debian packages for NTP on Debian bookworm (12) and trixie (13).

## Structure

- `packaging.Dockerfile` - Dockerfile for building NTP in clean Debian containers
- `packaging.mk` - Build commands for building and testing packages
- `../packaging/output` - Directory where .deb files are copied (created on first build)

## Quick Start

### Build for Debian Bookworm

```bash
make -f packaging.mk build DEBIAN_RELEASE=bookworm
```

### Build for Debian Trixie

```bash
make -f packaging.mk build DEBIAN_RELEASE=trixie
```

### Test Installation

```bash
make -f packaging.mk test DEBIAN_RELEASE=bookworm
make -f packaging.mk test DEBIAN_RELEASE=trixie
```

### Clean Build Artifacts

```bash
make -f packaging.mk clean DEBIAN_RELEASE=bookworm
make -f packaging.mk clean DEBIAN_RELEASE=trixie
```

## Usage

### Build a Package

The `make build` command:
1. Builds a Docker image with the specified Debian release
2. Installs all build dependencies
3. Runs `dpkg-buildpackage` to build the NTP package

### Test Installation

The `make test` command:
1. Runs a fresh Debian container
2. Installs the built .deb package
3. Verifies installation with `dpkg -l`

### GitHub Actions

The workflow in `.github/workflows/build.yml` automatically:
- Builds for both bookworm and trixie on push/PR
- Uploads build artifacts
- Tests installation in clean containers
- Runs on Ubuntu runners with Docker available

## Build Output

After building, the `docker/build-results/` directory will contain:
- `ntp_1:4.2.8p18+dfsg-1_amd64.deb` - Main NTP daemon package
- `ntpdate_1:4.2.8p18+dfsg-1_amd64.deb` - NTP client package
- `sntp_1:4.2.8p18+dfsg-1_amd64.deb` - SNTP client package
- `ntp-doc_1:4.2.8p18+dfsg-1_all.deb` - Documentation package

## Signing Packages

To build signed packages, modify `Dockerfile.build`:
1. Add `devscripts` to the apt-get install list
2. Change the RUN command to: `RUN dpkg-buildpackage -us -uc && debsign`

Or use the `-k` flag with a specific key:
```dockerfile
RUN dpkg-buildpackage -k<keyid>
```

## Notes

- Builds are architecture-specific (amd64, arm64, etc.)
- Containers are NOT automatically cleaned up for debugging
- Use `make clean` to remove build artifacts and Docker images
- The build uses `dpkg-buildpackage -us -uc` (unsigned, no changelog signing)
