# Stage 1: compile INDI, INDI-3rdparty, and PHD2 once. Docker caches each step,
# so ISO rebuilds do not recompile unchanged components.
FROM debian:trixie AS components

ARG CHANNEL=stable
ENV DEBIAN_FRONTEND=noninteractive CHANNEL=${CHANNEL} STAGE_DIR=/stage

COPY scripts/build /opt/galileo-build
RUN chmod +x /opt/galileo-build/*.sh
RUN /opt/galileo-build/install-build-deps.sh
RUN /opt/galileo-build/build-indi.sh
RUN /opt/galileo-build/build-indi-3rdparty.sh
RUN /opt/galileo-build/build-phd2.sh
RUN /opt/galileo-build/runtime-deps.sh > /stage-runtime-packages.txt \
    && cat /stage-runtime-packages.txt \
    && rm -rf /stage/usr/include /stage/usr/lib/*/cmake /stage/usr/lib/*/pkgconfig \
        /stage/usr/lib/cmake /stage/usr/lib/pkgconfig /stage/usr/share/pkgconfig \
    && find /stage -name '*.a' -delete \
    && mkdir -p /stage/usr/share/galileo \
    && (cd /stage && find . \( -type f -o -type l \) | sed 's|^\.||' | sort) > /stage-manifest.txt \
    && install -m 0644 /stage-manifest.txt /stage/usr/share/galileo/stage-manifest.txt

# Stage 2: the ISO builder.
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        ca-certificates \
        debootstrap \
        dosfstools \
        grub-efi-amd64-bin \
        grub-pc-bin \
        live-build \
        mtools \
        squashfs-tools \
        xorriso \
    && rm -rf /var/lib/apt/lists/*

COPY --from=components /stage /opt/galileo-stage/rootfs
COPY --from=components /stage-runtime-packages.txt /opt/galileo-stage/runtime-packages.txt

WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "/workspace/images/amd64-test/build-iso.sh"]
