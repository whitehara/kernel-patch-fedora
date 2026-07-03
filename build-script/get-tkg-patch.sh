#!/bin/bash
# Check and sync tracked linux-tkg patches for a given kernel version.
#
# Usage:
#   get-tkg-patch.sh <version>       -- show upstream changes since last sync
#   get-tkg-patch.sh <version> -d    -- copy changed patches and update sync marker
#
# .linux-tkg-sync (in build-script/) records the last synced linux-tkg commit.
# Diff is computed against it on each run, so results do not depend on
# session memory. Counterpart of get-cachos-patch.sh / .cachos-patches.

TKG_REPO="$HOME/git/kernel/linux-tkg"
SYNC_FILE="$(cd "$(dirname "$0")" && pwd)/.linux-tkg-sync"

# Master list of tracked linux-tkg patches (single source of truth;
# CLAUDE.md Step 2/6 refer to this list).
TRACKED=(
    0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch
    0001-bore.patch
    0002-clear-patches.patch
    0003-glitched-base.patch
    0003-glitched-cfs.patch
    0003-glitched-eevdf-additions.patch
    0006-add-acs-overrides_iommu.patch
    0009-prjc.patch
    0012-misc-additions.patch
    0013-optimize_harder_O3.patch
    0014-OpenRGB.patch
)
# Shown in diffs but never copied: the local file is CachyOS's version
# (sched/0001-bore.patch overwrites the TKg one — see CLAUDE.md Step 6).
NO_COPY=(0001-bore.patch)

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <version> [-d]"
    exit 1
fi
if [ ! -d "../$1" ]; then
    echo "No such directory: ../$1"
    exit 1
fi
VER="$1"
DOWNLOAD=0
[ "${2:-}" = "-d" ] && DOWNLOAD=1
PATCH_DIR="$(cd "../$VER" && pwd)"

if [ ! -d "$TKG_REPO/.git" ]; then
    echo "Error: linux-tkg repo not found: $TKG_REPO"
    exit 1
fi
if [ ! -f "$SYNC_FILE" ]; then
    echo "Error: sync marker not found: $SYNC_FILE"
    echo "Create it with the last synced linux-tkg commit hash."
    exit 1
fi

echo "=== linux-tkg patch status for kernel $VER ==="
echo ""

git -C "$TKG_REPO" pull --quiet 2>/dev/null \
    || echo "warning: git pull failed (offline?) — using local state"

SYNC=$(git -C "$TKG_REPO" rev-parse "$(head -1 "$SYNC_FILE")" 2>/dev/null)
if [ -z "$SYNC" ]; then
    echo "Error: commit in $SYNC_FILE not found in $TKG_REPO."
    exit 1
fi
HEAD=$(git -C "$TKG_REPO" rev-parse HEAD)

echo "Last synced: $(git -C "$TKG_REPO" log --oneline -1 "$SYNC")"
echo "Upstream   : $(git -C "$TKG_REPO" log --oneline -1 HEAD)"
echo ""

TRACKED_PATHS=()
for p in "${TRACKED[@]}"; do
    TRACKED_PATHS+=("linux-tkg-patches/$VER/$p")
done

CHANGED=$(git -C "$TKG_REPO" diff --name-only "$SYNC" "$HEAD" -- "${TRACKED_PATHS[@]}")

if [ -z "$CHANGED" ]; then
    echo "No changes in tracked linux-tkg patches since last sync."
    if [ "$DOWNLOAD" = "1" ] && [ "$SYNC" != "$HEAD" ]; then
        echo "$HEAD" > "$SYNC_FILE"
        echo "Sync marker advanced to HEAD: $SYNC_FILE"
    elif [ "$SYNC" != "$HEAD" ]; then
        echo "(Run with -d to advance the sync marker to HEAD.)"
    fi
    exit 0
fi

echo "Changed tracked patches:"
echo "$CHANGED" | sed 's/^/  /'
echo ""
echo "Commits touching tracked patches:"
git -C "$TKG_REPO" log --oneline "$SYNC".."$HEAD" -- "${TRACKED_PATHS[@]}"
echo ""
git -C "$TKG_REPO" diff "$SYNC" "$HEAD" -- "${TRACKED_PATHS[@]}"
echo ""

if [ "$DOWNLOAD" = "1" ]; then
    echo "Copying changed patches to $PATCH_DIR ..."
    echo "NOTE: local fixes in these files are overwritten — re-run kernel-mock.sh -t after."
    while IFS= read -r path; do
        file="${path##*/}"
        printf "  %-60s ... " "$file"
        skip=0
        for n in "${NO_COPY[@]}"; do
            [ "$file" = "$n" ] && skip=1
        done
        if [ "$skip" = "1" ]; then
            echo "skipped (CachyOS version is used; update via get-cachos-patch.sh)"
            continue
        fi
        if [ ! -f "$PATCH_DIR/$file" ]; then
            echo "skipped (not present locally — intentionally excluded per spec-mod.sh)"
            continue
        fi
        cp "$TKG_REPO/$path" "$PATCH_DIR/$file"
        echo "ok"
    done <<< "$CHANGED"
    echo "$HEAD" > "$SYNC_FILE"
    echo ""
    echo "Sync marker updated: $SYNC_FILE"
else
    echo "Run with -d to copy changed patches and update the sync marker."
fi
