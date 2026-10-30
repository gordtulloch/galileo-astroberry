#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
output_dir="$repo_root/dist"

for command in lb xorriso; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required build tool not found: $command" >&2
        exit 1
    fi
done

# debootstrap cannot extract a chroot onto a Windows bind mount (no Linux
# ownership, symlinks or device nodes), so build on the container's own
# filesystem and copy only the source configuration there.
work_dir=${GALILEO_WORK_DIR:-/var/tmp/galileo-amd64-build}
rm -rf "$work_dir"
mkdir -p "$output_dir" "$work_dir/config/hooks/normal" "$work_dir/config/package-lists"
cp -a "$script_dir"/config/package-lists/galileo-*.list.chroot "$work_dir/config/package-lists/"
cp -a "$script_dir/config/includes.chroot" "$work_dir/config/"

# INDI, INDI-3rdparty, and PHD2 were compiled in the Docker image; overlay them
# and install the Debian runtime libraries they need.
cp -a /opt/galileo-stage/rootfs/. "$work_dir/config/includes.chroot/"
{
    echo "# Runtime libraries for the compiled astronomy components (generated)."
    cat /opt/galileo-stage/runtime-packages.txt
} > "$work_dir/config/package-lists/galileo-components.list.chroot"
cp -a "$script_dir"/config/hooks/normal/09*.chroot "$work_dir/config/hooks/normal/"
[ -d "$script_dir/auto" ] && cp -a "$script_dir/auto" "$work_dir/"
[ -d "$script_dir/local" ] && cp -a "$script_dir/local" "$work_dir/"
cd "$work_dir"

lb clean
lb config \
    --distribution trixie \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --debian-installer live \
    --archive-areas "main contrib non-free-firmware" \
    --apt-recommends false \
    --bootappend-live "boot=live components username=galileo hostname=galileo"

chmod +x config/hooks/normal/*.chroot config/includes.chroot/usr/local/sbin/* config/includes.chroot/usr/local/bin/*
echo "Package lists passed to live-build:"
grep -Hv "^#" config/package-lists/*.list.chroot | grep -v ":$" | cut -d: -f2 | tr '\n' ' '
echo
lb build

iso="$work_dir/live-image-amd64.hybrid.iso"
if [ ! -s "$iso" ]; then
    echo "live-build did not produce the expected ISO: $iso" >&2
    exit 1
fi

"$script_dir/validate-iso.sh" "$iso"

version=$(date -u +%Y%m%d)
artifact="$output_dir/galileo-linux-amd64-smoke-$version.iso"
cp "$iso" "$artifact"
chmod 0644 "$artifact"
sha256sum "$artifact" > "$artifact.sha256"

echo "Built ISO: $artifact"
