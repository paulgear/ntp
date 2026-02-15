# NTP Debian Package Build System

Instructions for creating Debian packages for NTP

This works on all currently supported stable Debian releases as at the date of writing:
- bullseye (11) - oldoldstable
- bookworm (12) - oldstable
- trixie (13) - stable

All builds use Docker for reproducible build environments.

## Structure

- `packaging.Dockerfile` - Dockerfile for building NTP in clean Debian containers
- `packaging.mk` - Build commands for building and testing packages
- `../packaging/output` - Directory where .deb files are copied (created on first build)

## Quick Start

Build for a Debian release:

```bash
make -f packaging.mk build DEBIAN_RELEASE=(bullseye|bookworm|trixie)
```

## Make targets

- test: installs all of the packages from build in a clean Docker container for that Debian release
### buildcontainer: create the build container

1. Builds a Docker image based on debian:$(RELEASE), called deb-build:$(RELEASE)
2. Installs base packages needed for all dpkg builds
3. Installs build dependencies for ntp packages

Build calls this automatically.  The first time it is run on a host can take a few minutes due to pulling the docker image and installing the packages.  After this it should be quite fast due to Docker's layer cache.

### build: create the Debian packages

1. Runs in a container from the deb-build:$(RELEASE) image
2. Creates an archive of the current git HEAD commit
3. Copies the archive and the working directory's copy of the debian/ folder into the output directory
4. Runs `dpkg-buildpackage` to build the NTP package

### test: install the Debian packages in a fresh container

1. Runs a fresh container using debian:$(RELEASE)
2. Installs the built .deb packages from the output directory
3. Verifies installation with `dpkg -l`

### clean: remove build artifacts

Removes the build results, including the extracted source tree and the Debian packages.  This requires sudo because even though they're built locally as an ordinary user, the files get created inside the container with root permissions.

### dockerclean: remove build image

In case you're short on space or not expecting to come back to this for a while, `dockerclean` removes the container image created by `buildcontainer`.

### all: convenience target

Performs in order: clean, buildcontainer, build, test - this is useful for testing the end-to-end process once you're confident the build is working reliably.

## GitHub Actions

The workflow in `.github/workflows/build.yml` automatically:
- Builds for all supported releases on push/PR
- Tests installation in clean containers
- Uploads build artifacts to GitHub releases

## Build Output

After building, the output directory will contain:

- `ntp/` - source directory used for build
- `ntp_$VERSION+dfsg-1_$ARCH.buildinfo`, `ntp_$VERSION+dfsg-1_$ARCH.changes`, `ntp_$VERSION+dfsg-1.dsc` - Debian packaging artifacts
- `ntp_$VERSION+dfsg-1_$ARCH.deb` - the main NTP daemon package
- `ntp_$VERSION+dfsg-1.debian.tar.xz` - `debian/` source tarball
- `ntp_$VERSION+dfsg.orig.tar.gz` - upstream source tarball (from `git archive HEAD`)
- `ntpdate_$VERSION+dfsg-1_$ARCH.deb` - obsolete NTP client package
- `ntp-doc_$VERSION+dfsg-1_all.deb` - Documentation package
- `sntp_$VERSION+dfsg-1_$ARCH.deb` - preferred SNTP client package

## Signing Packages

Yet to be tested; eventually to build signed packages, modify `packaging.Dockerfile`:
1. Add `devscripts` to the `apt-get install` list
2. Change the RUN command to: `RUN dpkg-buildpackage -us -uc && debsign`
or use the `-k` flag with a specific key: `RUN dpkg-buildpackage -k<keyid>`

## Notes

- Builds are architecture-specific to the host on which they're built (amd64, arm64, etc.)
- Containers are NOT automatically cleaned up for debugging
- The build uses `dpkg-buildpackage -us -uc` (unsigned, no changelog signing)
