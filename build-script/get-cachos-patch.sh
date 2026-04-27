#!/bin/bash
# Check and sync CachyOS patches for a given kernel version.
#
# Usage:
#   get-cachos-patch.sh <version>       -- show available patches and diff vs manifest
#   get-cachos-patch.sh <version> -d    -- show diff and download
#
# Manifest (.cachos-patches in the patch directory) tracks which patches
# were downloaded from CachyOS. Diff is computed against it on each run.

if [ ! -d "../$1" ]; then
    echo "No such directory: ../$1"
    exit 1
fi
VER="$1"
DOWNLOAD=0
[ "${2:-}" = "-d" ] && DOWNLOAD=1

PATCH_DIR="$(cd "../$VER" && pwd)"
API_BASE="https://api.github.com/repos/CachyOS/kernel-patches/contents/$VER"
RAW_BASE="https://raw.githubusercontent.com/CachyOS/kernel-patches/refs/heads/master/$VER"
MANIFEST="$PATCH_DIR/.cachos-patches"

# List .patch filenames from a GitHub API directory URL
list_remote() {
    wget -q -O - "$1" 2>/dev/null \
        | grep -oE '"name" *: *"[^"]*\.patch"' \
        | sed 's/.*"\([^"]*\.patch\)"/\1/'
}

cleanup() {
    rm -f "$remote_tmp" "$prev_tmp" "$new_tmp" "$removed_tmp"
}
trap cleanup EXIT

echo "=== CachyOS patch status for kernel $VER ==="
echo ""

# --- Detect structure ---
sched_names=$(list_remote "$API_BASE/sched")

if [ -n "$sched_names" ]; then
    # New structure (7.0+): sched/ + misc/
    misc_names=$(list_remote "$API_BASE/misc")

    echo "Remote patches:"
    echo "  sched/ :"
    for p in $sched_names; do echo "    $p"; done
    echo "  misc/  :"
    for p in $misc_names;  do echo "    $p"; done
    echo ""

    # Build remote entry list ("sched/file.patch", "misc/file.patch")
    remote_tmp=$(mktemp)
    for p in $sched_names; do echo "sched/$p" >> "$remote_tmp"; done
    for p in $misc_names;  do echo "misc/$p"  >> "$remote_tmp"; done

    # Load previous manifest
    prev_tmp=$(mktemp)
    [ -f "$MANIFEST" ] && cp "$MANIFEST" "$prev_tmp"

    # Compute diff (requires sorted input for comm)
    new_tmp=$(mktemp)
    removed_tmp=$(mktemp)
    comm -23 <(sort "$remote_tmp") <(sort "$prev_tmp") > "$new_tmp"
    comm -13 <(sort "$remote_tmp") <(sort "$prev_tmp") > "$removed_tmp"

    if [ ! -s "$new_tmp" ] && [ ! -s "$removed_tmp" ]; then
        echo "No changes in CachyOS patch list."
    else
        if [ -s "$new_tmp" ]; then
            echo "NEW patches (not yet downloaded):"
            sed 's/^/  + /' "$new_tmp"
        fi
        if [ -s "$removed_tmp" ]; then
            echo ""
            echo "REMOVED from CachyOS (local file kept — review spec-mod.sh if referenced):"
            sed 's/^/  - /' "$removed_tmp"
        fi
    fi

    if [ "$DOWNLOAD" = "1" ]; then
        echo ""
        echo "Downloading all remote patches..."
        while IFS= read -r entry; do
            dir="${entry%%/*}"
            file="${entry#*/}"
            printf "  %-40s ... " "$entry"
            wget -q -O "$PATCH_DIR/$file" "$RAW_BASE/$dir/$file"
            echo "ok"
        done < "$remote_tmp"
        cp "$remote_tmp" "$MANIFEST"
        echo ""
        echo "Manifest saved: $MANIFEST"
    else
        echo ""
        echo "Run with -d to download."
    fi

else
    all_names=$(list_remote "$API_BASE/all")
    if [ -n "$all_names" ]; then
        # Old structure (≤6.17): all/0001-cachyos-base-all.patch
        echo "Old structure: all/0001-cachyos-base-all.patch"
        echo ""
        local_patch="$PATCH_DIR/0001-cachyos-base-all.patch"
        tmp_patch=$(mktemp)
        wget -O "$tmp_patch" "$RAW_BASE/all/0001-cachyos-base-all.patch"
        sed -i -e "s/BUFSIZE 256/BUFSIZE 4096/g" "$tmp_patch"
        if [ -f "$local_patch" ]; then
            diff -u --color "$local_patch" "$tmp_patch" || true
        fi
        if [ "$DOWNLOAD" = "1" ]; then
            mv "$tmp_patch" "$local_patch"
            echo "Updated: $local_patch"
        else
            rm -f "$tmp_patch"
            echo "Run with -d to download/update."
        fi
    else
        echo "ERROR: No CachyOS patches found for kernel $VER."
        echo "Check: https://github.com/CachyOS/kernel-patches"
        exit 1
    fi
fi
