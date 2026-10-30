# Builder for the Debian Trixie + Astroberry OS amd64 smoke ISO.
# Unlike images/amd64-test, nothing is compiled here: INDI, PHD2, the drivers
# and Astroberry Manager all come from Astroberry's own APT repository.
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        curl \
        debootstrap \
        dosfstools \
        gnupg \
        grub-efi-amd64-bin \
        grub-pc-bin \
        live-build \
        mtools \
        squashfs-tools \
        xorriso \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "/workspace/images/astroberry-test/build-iso.sh"]
