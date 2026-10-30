#!/bin/bash
# Build a Debian 13 (Trixie) amd64 live/install ISO with Astroberry OS installed
# from Astroberry's APT repository. Astroberry is installed exactly as its
# documentation describes (repository + pin + `apt install astroberry-os`);
# nothing of Astroberry is modified.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
output_dir="$repo_root/dist"

repo_url=${ASTROBERRY_REPO_URL:-https://astroberry.io/debian}
# Signing key of the stable `trixie` distribution (astroberry-os docs/ARCHITECTURE.md).
key_fingerprint=B9EA22DE1118CEE6F40494357E8C9FBE975B014A

for command in lb xorriso curl gpg; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required build tool not found: $command" >&2
        exit 1
    fi
done

# debootstrap cannot extract a chroot onto a Windows bind mount, so build on the
# container's own filesystem and copy only the source configuration there.
work_dir=${GALILEO_WORK_DIR:-/var/tmp/astroberry-amd64-build}
rm -rf "$work_dir"
mkdir -p "$output_dir" "$work_dir"
cp -a "$script_dir/config" "$work_dir/"
cd "$work_dir"

# Astroberry's repository, key and pin, registered the way live-build expects so
# that its own `apt update` sees the repository before packages are installed.
# The .list and .key stay in the finished image, as the documented install leaves
# them on a normal system.
mkdir -p config/archives config/includes.chroot_before_packages/etc/apt/preferences.d
curl -fsSL "$repo_url/astroberry.asc" -o config/archives/astroberry.key
curl -fsSL "$repo_url/astroberry-pin" -o config/includes.chroot_before_packages/etc/apt/preferences.d/astroberry-pin
cat > config/archives/astroberry.list <<EOF
deb $repo_url trixie main
EOF

# Refuse to continue if the downloaded key is not the documented signing key.
fingerprints=$(gpg --show-keys --with-colons config/archives/astroberry.key | awk -F: '$1=="fpr"{print $10}')
if ! printf '%s\n' "$fingerprints" | grep -qx "$key_fingerprint"; then
    echo "Astroberry repository key does not include the expected fingerprint $key_fingerprint." >&2
    printf '%s\n' "$fingerprints" >&2
    exit 1
fi

# Boot the Live system straight away instead of waiting at the boot menu. Patch
# copies of live-build's own bootloader templates (BIOS: isolinux, UEFI/GRUB) so
# newer template changes are still picked up. Holding Shift (GRUB) or pressing a
# key is no longer needed; fail-safe mode is not offered at boot.
templates=/usr/share/live/build/bootloaders
mkdir -p config/bootloaders
cp -a "$templates"/. config/bootloaders/
sed -i -e 's/^default .*/default live-amd64/' -e 's/^timeout .*/timeout 1/' \
    config/bootloaders/isolinux/isolinux.cfg config/bootloaders/syslinux/syslinux.cfg
grep -q '^default live-amd64' config/bootloaders/isolinux/isolinux.cfg
# `set timeout=0` makes GRUB boot the default entry without showing the menu.
printf 'set timeout=0\nset timeout_style=hidden\n' | cat - config/bootloaders/grub-pc/config.cfg \
    > config/bootloaders/grub-pc/config.cfg.new
mv config/bootloaders/grub-pc/config.cfg.new config/bootloaders/grub-pc/config.cfg

lb clean
lb config \
    --distribution trixie \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --debian-installer none \
    --archive-areas "main contrib non-free-firmware" \
    --debootstrap-options "--include=ca-certificates,gnupg" \
    --firmware-chroot false \
    --bootappend-live "boot=live components"

chmod +x config/hooks/normal/*.chroot
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
artifact="$output_dir/debian-trixie-astroberry-amd64-smoke-$version.iso"
cp "$iso" "$artifact"
chmod 0644 "$artifact"
(cd "$output_dir" && sha256sum "$(basename "$artifact")" > "$(basename "$artifact").sha256")

echo "Built ISO: $artifact"
