#!/bin/bash
# Build and install the INDI-3rdparty libraries and drivers. Requires INDI
# (build-indi.sh) to be installed first. The libraries must be built and
# installed before the drivers that link against them, as in astro-soft-build.
. "$(dirname "$0")/lib.sh"

checkout_source indi-3rdparty "$INDI_3RDPARTY_URL" "$INDI_3RDPARTY_STABLE_REF"
BUILD_NAME=indi-3rdparty-libs cmake_build indi-3rdparty . -DBUILD_LIBS=1
BUILD_NAME=indi-3rdparty-drivers cmake_build indi-3rdparty .
record_version indi-3rdparty
