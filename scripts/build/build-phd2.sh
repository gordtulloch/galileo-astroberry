#!/bin/bash
# Build and install PHD2 against the system libusb and the INDI installed by
# build-indi.sh instead of PHD2's bundled copies. cfitsio, Eigen, cURL, and
# libnova are always taken from the system on Linux.
. "$(dirname "$0")/lib.sh"

checkout_source phd2 "$PHD2_URL" "$PHD2_STABLE_REF"
cmake_build phd2 . \
    -DUSE_SYSTEM_LIBUSB=ON \
    -DUSE_SYSTEM_LIBINDI=ON
record_version phd2
