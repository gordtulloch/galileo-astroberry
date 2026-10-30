#!/bin/bash
# Shared helpers for the Galileo Linux component build scripts. Source this file.
#
# Environment:
#   CHANNEL    stable (default; pinned releases) or nightly (default branches)
#   BUILD_DIR  working tree for sources and build output (default /var/tmp/galileo-build)
#   PREFIX     install prefix (default /usr)
#   STAGE_DIR  if set, every component is also installed under this DESTDIR so
#              the files can be packaged into an image
#   JOBS       parallel jobs (default: limited by CPU count and memory)

set -euo pipefail

BUILD_LIB_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=versions.env
. "$BUILD_LIB_DIR/versions.env"

CHANNEL=${CHANNEL:-stable}
BUILD_DIR=${BUILD_DIR:-/var/tmp/galileo-build}
PREFIX=${PREFIX:-/usr}
STAGE_DIR=${STAGE_DIR:-}

case "$CHANNEL" in
    stable|nightly) ;;
    *) echo "CHANNEL must be 'stable' or 'nightly', not '$CHANNEL'." >&2; exit 2 ;;
esac

SUDO=
if [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
fi

# Build flags follow astro-soft-build, but without -march=native so the
# resulting binaries run on any x86-64 / arm64 machine, not just the builder.
export CFLAGS="${CFLAGS:--w -Wno-psabi -D_FILE_OFFSET_BITS=64}"
export CXXFLAGS="${CXXFLAGS:--w -Wno-psabi -D_FILE_OFFSET_BITS=64}"

if [ -z "${JOBS:-}" ]; then
    JOBS=$(nproc)
    # C++ compilation needs roughly 1.5 GB per job; avoid out-of-memory kills.
    mem_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    mem_jobs=$(( mem_kb / 1500000 ))
    [ "$mem_jobs" -lt 1 ] && mem_jobs=1
    [ "$mem_jobs" -lt "$JOBS" ] && JOBS=$mem_jobs
fi

mkdir -p "$BUILD_DIR/src" "$BUILD_DIR/build"

log() { echo "==> $*"; }

# retry COUNT COMMAND...
# Large upstream clones over a flaky link can end with "early EOF".
retry() {
    local tries=$1 attempt=1
    shift
    until "$@"; do
        if [ "$attempt" -ge "$tries" ]; then
            echo "Command failed after $tries attempts: $*" >&2
            return 1
        fi
        attempt=$((attempt + 1))
        log "Retrying (attempt $attempt of $tries): $*"
        sleep 10
    done
}

# checkout_source NAME URL STABLE_REF
# Shallow-clones (or updates) NAME under $BUILD_DIR/src and checks out the stable
# pin (a tag), or the remote default branch for the nightly channel. Shallow
# clones keep large repositories such as indi-3rdparty from failing with
# "early EOF" over a slow link.
checkout_source() {
    local name=$1 url=$2 stable_ref=$3
    local dir="$BUILD_DIR/src/$name"

    if [ ! -d "$dir/.git" ]; then
        log "Cloning $name"
        if [ "$CHANNEL" = stable ]; then
            retry 5 sh -c "rm -rf '$dir' && git clone --depth 1 --branch '$stable_ref' '$url' '$dir'"
        else
            retry 5 sh -c "rm -rf '$dir' && git clone --depth 1 '$url' '$dir'"
        fi
    elif [ "$CHANNEL" = stable ]; then
        retry 5 git -C "$dir" fetch --depth 1 --force origin "refs/tags/$stable_ref:refs/tags/$stable_ref"
    else
        retry 5 git -C "$dir" fetch --depth 1 origin HEAD
    fi
    if [ "$CHANNEL" = stable ]; then
        git -C "$dir" checkout --detach --force "$stable_ref"
    else
        git -C "$dir" checkout --detach --force FETCH_HEAD 2>/dev/null || git -C "$dir" checkout --detach --force HEAD
    fi
    log "$name at $(git -C "$dir" describe --tags --always) ($CHANNEL)"
}

# cmake_build NAME SRC_SUBDIR [CMAKE_ARGS...]
# Configures, builds, and installs a CMake project from $BUILD_DIR/src/NAME/SRC_SUBDIR.
# NAME is also the build directory name, so one source tree can be built twice
# with different arguments by giving each build a distinct NAME via BUILD_NAME.
cmake_build() {
    local name=$1 subdir=$2
    shift 2
    local src="$BUILD_DIR/src/$name/$subdir"
    local bld="$BUILD_DIR/build/${BUILD_NAME:-$name}"

    log "Configuring ${BUILD_NAME:-$name}"
    cmake -S "$src" -B "$bld" \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        "$@"
    log "Building ${BUILD_NAME:-$name} with $JOBS jobs"
    cmake --build "$bld" --parallel "$JOBS"
    log "Installing ${BUILD_NAME:-$name}"
    $SUDO cmake --install "$bld"
    if [ -n "$STAGE_DIR" ]; then
        DESTDIR="$STAGE_DIR" cmake --install "$bld"
    fi
    $SUDO ldconfig
}

# record_version NAME
# Writes the source revision under $PREFIX/share/galileo/versions so the
# installed component can be traced to a commit (PSD OPS-06, OPS-07).
record_version() {
    local name=$1
    local dir="$BUILD_DIR/src/$name"
    local file
    file=$(mktemp)
    {
        echo "component=$name"
        echo "channel=$CHANNEL"
        echo "describe=$(git -C "$dir" describe --tags --always)"
        echo "commit=$(git -C "$dir" rev-parse HEAD)"
        echo "url=$(git -C "$dir" remote get-url origin)"
        echo "built=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    } > "$file"
    local target="$PREFIX/share/galileo/versions"
    $SUDO install -D -m 0644 "$file" "$target/$name.txt"
    if [ -n "$STAGE_DIR" ]; then
        install -D -m 0644 "$file" "$STAGE_DIR$target/$name.txt"
    fi
    rm -f "$file"
}
