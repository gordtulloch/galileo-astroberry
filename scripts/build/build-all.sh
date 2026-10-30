#!/bin/bash
# Build and install INDI, INDI-3rdparty, and PHD2 in dependency order.
# Usage: [CHANNEL=stable|nightly] [STAGE_DIR=/path] ./build-all.sh
set -euo pipefail
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

"$dir/build-indi.sh"
"$dir/build-indi-3rdparty.sh"
"$dir/build-phd2.sh"
