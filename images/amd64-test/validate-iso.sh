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
for candidate in /live/filesystem.manifest /live/filesystem.packages; do
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

for package in openssh-server network-manager avahi-daemon tigervnc-standalone-server openbox novnc websockify; do
    if ! grep -Eq "^${package}([[:space:]]|$)" "$manifest"; then
        echo "ISO package manifest is missing required package: $package" >&2
        exit 1
    fi
done

echo "ISO validation passed: bootable ISO manifest has required packages and excludes brltty."
