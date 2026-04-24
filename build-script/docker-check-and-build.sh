#!/bin/bash
# Runs inside a Fedora docker container for GitHub Actions.
# Checks for a new kernel, tests patch application, updates README.md, and starts Copr builds.
#
# Prerequisites (mounted at /build):
#   /build/copr                        - Copr CLI config file
#   /build/build-script/kernel-mock.sh - Build script
#
# Limitations:
#   - Only handles minor version updates within the existing set of fc variants
#     (e.g., 6.19.13 -> 6.19.14 for fc42/fc43/fc44).
#   - Adding a new Fedora release (e.g., fc45) or a new major kernel series
#     (e.g., 6.19 -> 6.20) requires manual intervention:
#       1. Update build-script/support-vers manually.
#       2. Add the new entry/section to README.md manually.
#       3. Commit and push.

COPR_CONFIG=/build/copr

if [ ! -f "$COPR_CONFIG" ]; then
    echo "ERROR: Copr config not found at $COPR_CONFIG"
    exit 1
fi
if [ ! -f /build/build-script/kernel-mock.sh ]; then
    echo "ERROR: kernel-mock.sh not found at /build/build-script/kernel-mock.sh"
    exit 1
fi

echo "=== Install packages ==="
dnf -q -y install koji copr-cli mock gawk

echo "=== Check for new kernel ==="
LATEST_NVR=$(koji list-builds --package=kernel --state=COMPLETE --quiet \
    | awk '{print $1}' | grep '^kernel-' | grep -v '\.rc' | tail -n 1)
LATEST_BASE=$(echo "$LATEST_NVR" | sed -E 's/^kernel-([^-]+)-.*/\1/')
CURRENT_BASE=$(grep -v '^#' /build/build-script/support-vers \
    | grep -v '^[[:space:]]*$' | head -1 | sed -E 's/([^-]+)-.*/\1/')

if [ -z "$LATEST_BASE" ]; then
    echo "ERROR: Failed to retrieve latest kernel from Koji."
    exit 1
fi
if [ -z "$CURRENT_BASE" ]; then
    echo "ERROR: Failed to parse current version from support-vers."
    exit 1
fi

echo "Latest  : $LATEST_BASE"
echo "Current : $CURRENT_BASE"

if [ "$LATEST_BASE" = "$CURRENT_BASE" ]; then
    # Even if the base version matches, some fc variants may have been missing from
    # Koji on a previous run and left as stale entries in support-vers. Check for those.
    STALE_ENTRIES=$(grep -v '^#' /build/build-script/support-vers \
        | grep -v '^[[:space:]]*$' | grep -v "^${LATEST_BASE}-")
    if [ -z "$STALE_ENTRIES" ]; then
        echo "Already up to date. No action needed."
        exit 0
    fi
    echo "Base version matches but stale fc entries found:"
    echo "$STALE_ENTRIES"
fi

echo "=== New kernel detected: $LATEST_BASE ==="

# Save old support-vers before check-new-kernel.sh overwrites it
OLD_SUPPORT_VERS=$(grep -v '^#' /build/build-script/support-vers | grep -v '^[[:space:]]*$')

echo "=== Run check-new-kernel.sh ==="
cd /build/build-script
./check-new-kernel.sh
CHECK_RESULT=$?

if [ "$CHECK_RESULT" -ne 0 ]; then
    echo "ERROR: Patch application test failed. Aborting."
    exit 1
fi

echo "=== Update README.md ==="
while IFS= read -r OLD_NVRS; do
    [ -z "$OLD_NVRS" ] && continue
    FC=$(echo "$OLD_NVRS" | sed -E 's/.*\.fc([0-9]+)$/\1/')
    NEW_NVRS=$(grep -v '^#' /build/build-script/support-vers \
        | grep -v '^[[:space:]]*$' | grep "\.fc${FC}$" | head -1)
    if [ -z "$NEW_NVRS" ]; then
        echo "  WARNING: No new entry found for fc${FC}, skipping."
        continue
    fi
    BUILDID=$(koji buildinfo "kernel-$NEW_NVRS" | sed -n 's/^BUILD:.*\[\([0-9]*\)\].*/\1/p')
    if [ -z "$BUILDID" ]; then
        echo "  ERROR: Failed to get buildID for kernel-$NEW_NVRS. Aborting."
        exit 1
    fi
    echo "  fc${FC}: kernel-$OLD_NVRS -> kernel-$NEW_NVRS [buildID: $BUILDID]"
    sed -i "s|\[kernel-${OLD_NVRS}\](https://koji.fedoraproject.org/koji/buildinfo?buildID=[0-9]*)|\[kernel-${NEW_NVRS}\](https://koji.fedoraproject.org/koji/buildinfo?buildID=${BUILDID})|" /build/README.md
done <<< "$OLD_SUPPORT_VERS"

# Signal to the workflow that files are ready to commit and push
echo "$LATEST_BASE" > /build/.new_kernel_found

echo "=== Start Copr builds ==="
if ! ./kernel-mock.sh -c -f "$COPR_CONFIG"; then
    echo "ERROR: Copr build submission failed. Cancelling running builds."
    ./kernel-mock.sh -n -f "$COPR_CONFIG"
    exit 1
fi

echo "=== Done ==="
exit 0
