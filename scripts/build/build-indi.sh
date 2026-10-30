#!/bin/bash
# Build and install the INDI core library and server.
. "$(dirname "$0")/lib.sh"

checkout_source indi "$INDI_URL" "$INDI_STABLE_REF"
cmake_build indi .
record_version indi
