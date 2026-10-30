#!/bin/bash
# Build and install the Galileo desktop application (PySide6) into a virtual
# environment at $GALILEO_VENV, plus a /usr/bin/galileo launcher.
#
# Uses the same environment as the scripts in scripts/build (CHANNEL, BUILD_DIR,
# PREFIX, STAGE_DIR). The venv has absolute paths baked in, so it is built at its
# final location and copied unchanged into STAGE_DIR.
set -euo pipefail

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=../build/lib.sh
. "${GALILEO_BUILD_DIR:-$here/../build}/lib.sh"
# shellcheck source=galileo.env
. "$here/galileo.env"

log "Installing Python build prerequisites"
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update
$SUDO apt-get install --yes --no-install-recommends \
    git python3 python3-venv python3-dev python3-pip build-essential

checkout_source galileo "$GALILEO_URL" "$GALILEO_STABLE_REF"

log "Creating virtual environment at $GALILEO_VENV"
$SUDO rm -rf "$GALILEO_VENV"
$SUDO python3 -m venv "$GALILEO_VENV"
$SUDO "$GALILEO_VENV/bin/pip" install --no-cache-dir --upgrade pip
log "Installing Galileo and its Python dependencies"
$SUDO "$GALILEO_VENV/bin/pip" install --no-cache-dir "$BUILD_DIR/src/galileo"

launcher=$(mktemp)
cat > "$launcher" <<LAUNCHER
#!/bin/sh
exec "$GALILEO_VENV/bin/galileo" "\$@"
LAUNCHER
$SUDO install -D -m 0755 "$launcher" "$PREFIX/bin/galileo"

if [ -n "$STAGE_DIR" ]; then
    mkdir -p "$STAGE_DIR$(dirname "$GALILEO_VENV")"
    rm -rf "${STAGE_DIR:?}$GALILEO_VENV"
    cp -a "$GALILEO_VENV" "$STAGE_DIR$GALILEO_VENV"
    install -D -m 0755 "$launcher" "$STAGE_DIR$PREFIX/bin/galileo"
fi
rm -f "$launcher"

record_version galileo
