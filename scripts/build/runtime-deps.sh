#!/bin/bash
# Print the Debian runtime packages needed by the ELF files under STAGE_DIR,
# one per line. Used to build the image package list so the image carries only
# runtime libraries, not the -dev packages used for compilation.
# Usage: STAGE_DIR=/path ./runtime-deps.sh > runtime-packages.txt
set -euo pipefail

stage=${STAGE_DIR:?STAGE_DIR must point at the staged install tree}

# Libraries shipped inside the stage are not Debian packages.
export LD_LIBRARY_PATH="$stage/usr/lib:$stage/usr/lib/$(gcc -dumpmachine):${LD_LIBRARY_PATH:-}"

find "$stage" -type f \( -perm -u+x -o -name '*.so*' \) -print0 |
    while IFS= read -r -d '' file; do
        if [ "$(head -c 4 "$file" 2>/dev/null | tr -d '\0')" = $'\177ELF' ]; then
            ldd "$file" 2>/dev/null | awk '/=> \// {print $3}'
        fi
    done |
    sort -u |
    while IFS= read -r lib; do
        real=$(readlink -f "$lib")
        case "$real" in "$stage"*) continue ;; esac
        dpkg-query -S "$real" 2>/dev/null | head -n1 | cut -d: -f1
    done |
    sort -u
