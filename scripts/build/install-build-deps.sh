#!/bin/bash
# Install the Debian packages needed to compile INDI, INDI-3rdparty, and PHD2.
# Package choices follow astro-soft-build's install-dependencies.sh, minus the
# KDE/KStars packages the Galileo image does not build.
set -euo pipefail

SUDO=
[ "$(id -u)" -ne 0 ] && SUDO=sudo

export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update
$SUDO apt-get install --yes --no-install-recommends \
    build-essential ca-certificates cmake git pkg-config gettext \
    libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev \
    libjpeg-dev libcurl4-gnutls-dev libtiff-dev libfftw3-dev libftdi1-dev \
    libgps-dev libraw-dev libdc1394-dev libgphoto2-dev libboost-dev \
    libboost-regex-dev librtlsdr-dev liblimesuite-dev libavcodec-dev \
    libavdevice-dev libeigen3-dev libev-dev libzmq3-dev libudev-dev \
    libopencv-dev libogg-dev libtheora-dev libwxgtk3.2-dev \
    libgtk-3-dev libglib2.0-dev
