#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <iso-path>" >&2
    exit 2
fi

iso=$1
if [ ! -f "$iso" ] || [ ! -s "$iso" ]; then
    echo "ISO does not exist or is empty: $iso" >&2
    exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

xorriso -indev "$iso" -report_el_torito plain > "$tmpdir/boot-report.txt" 2>&1
if ! grep -qi 'El Torito' "$tmpdir/boot-report.txt"; then
    echo "ISO has no El Torito boot catalog." >&2
    exit 1
fi

manifest=
for candidate in /live/filesystem.packages /live/filesystem.manifest; do
    if xorriso -osirrox on -indev "$iso" -extract "$candidate" "$tmpdir/manifest" \
        >/dev/null 2>&1; then
        manifest=$tmpdir/manifest
        break
    fi
done
if [ -z "$manifest" ]; then
    echo "Could not extract a package manifest from the ISO." >&2
    exit 1
fi

if grep -Eq '^brltty([[:space:]]|$)' "$manifest"; then
    echo "ISO package manifest includes brltty." >&2
    exit 1
fi

for package in astroberry-os-sysmod astroberry-manager indi-bin phd2 openssh-server calamares calamares-settings-debian grub-pc-bin grub-efi-amd64-bin; do
    if ! grep -Eq "^${package}([[:space:]]|$)" "$manifest"; then
        echo "ISO package manifest is missing required package: $package" >&2
        exit 1
    fi
done

for package in kstars kstars-bleeding; do
    if grep -Eq "^${package}([[:space:]]|$)" "$manifest"; then
        echo "ISO package manifest includes $package, which is not wanted." >&2
        exit 1
    fi
done

# The boot menus must start the Live system without waiting for input.
if ! xorriso -osirrox on -indev "$iso" -extract /isolinux/isolinux.cfg "$tmpdir/isolinux.cfg" >/dev/null 2>&1 \
    || ! grep -qx 'default live-amd64' "$tmpdir/isolinux.cfg" \
    || ! grep -qx 'timeout 1' "$tmpdir/isolinux.cfg"; then
    echo "BIOS boot menu does not auto-start the Live system (isolinux.cfg)." >&2
    exit 1
fi
if ! xorriso -osirrox on -indev "$iso" -extract /boot/grub/config.cfg "$tmpdir/config.cfg" >/dev/null 2>&1 \
    || ! grep -qx 'set timeout=0' "$tmpdir/config.cfg"; then
    echo "UEFI boot menu does not auto-start the Live system (grub config.cfg)." >&2
    exit 1
fi

echo "Astroberry versions in the ISO:"
grep -E '^(astroberry-[a-z-]+|indi-bin|libindi1|phd2)([[:space:]]|$)' "$manifest"

echo "ISO validation passed: bootable ISO manifest has the Astroberry packages and excludes brltty."
