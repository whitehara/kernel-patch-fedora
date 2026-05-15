#!/bin/bash

# Move to the script's directory
cd "$(dirname "$0")"

HISTORY_FILE="../HISTORY.md"
SUPPORT_VERS="support-vers"
LOCKFILE="../results/.check-new-kernel.lock"

# Prevent concurrent runs (parallel mock invocations corrupt shared chroots).
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    echo "Another check-new-kernel.sh is already running (lockfile: $LOCKFILE). Aborting."
    exit 1
fi

echo "Checking for the latest kernel builds on Fedora Koji..."

# Determine active series from top-level directories (e.g. 6.19, 7.0).
# Exclude archive/ and other non-version directories.
ACTIVE_SERIES=$(cd .. && for d in [0-9]*.[0-9]*; do [ -d "$d" ] && echo "$d"; done | sort -V)

if [ -z "$ACTIVE_SERIES" ]; then
    echo "Error: No active kernel series directories found."
    exit 1
fi
echo "Active series: $(echo "$ACTIVE_SERIES" | tr '\n' ' ')"

# Tested NVRs from HISTORY.md (lines starting with 'kernel-').
if [ ! -f "$HISTORY_FILE" ]; then
    echo "Error: $HISTORY_FILE not found."
    exit 1
fi
TESTED_NVRS=$(grep '^kernel-' "$HISTORY_FILE" | sort -u)

# For each (active series, fcXX), pick the chronologically latest NVR from koji.
# koji list-builds returns builds in chronological order (oldest first), so tail -n 1
# gives the latest. We restrict the search to active series base versions only.
NEW_NVRS=""
for SERIES in $ACTIVE_SERIES; do
    # Pull all completed builds for this series in one call.
    ALL_BUILDS=$(koji list-builds --package=kernel --state=COMPLETE --quiet \
                 | awk '{print $1}' \
                 | grep "^kernel-${SERIES}\." \
                 | grep -v '\.rc')
    [ -z "$ALL_BUILDS" ] && continue

    for FC in fc42 fc43 fc44; do
        LATEST=$(echo "$ALL_BUILDS" | grep "\.${FC}\$" | tail -n 1)
        [ -z "$LATEST" ] && continue
        if ! echo "$TESTED_NVRS" | grep -qFx "$LATEST"; then
            NEW_NVRS+="${LATEST#kernel-}"$'\n'
        fi
    done
done

# Strip trailing newline.
NEW_NVRS=$(echo -n "$NEW_NVRS" | sed '/^$/d')

if [ -z "$NEW_NVRS" ]; then
    echo "All latest kernel builds in active series are already in HISTORY.md."
    exit 0
fi

echo "New kernel NVRs detected:"
echo "$NEW_NVRS"

# Rewrite support-vers: new NVRs first, then keep comments / non-NVR lines from prior file.
cp "$SUPPORT_VERS" "${SUPPORT_VERS}.bak"
{
    echo "$NEW_NVRS"
    # Preserve comment / blank lines from the prior file (e.g. #EOF).
    grep -E '^(#|$)' "${SUPPORT_VERS}.bak"
} > "${SUPPORT_VERS}.tmp"
mv "${SUPPORT_VERS}.tmp" "$SUPPORT_VERS"
echo "Updated $SUPPORT_VERS. Starting tests..."

# Clear the previous test failure log
rm -f ../results/failed_tests.log

# Execute with -t option (tests patch application only, returns success/failure as exit status)
./kernel-mock.sh -t
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "All patch application tests succeeded."
    # Append tested NVRs to HISTORY.md under a new dated section.
    TODAY=$(date +%Y-%m-%d)
    {
        # Insert new section right after the file header (before the first existing "## ").
        awk -v today="$TODAY" -v nvrs="$NEW_NVRS" '
            BEGIN { inserted=0 }
            /^## / && !inserted {
                print "## " today
                n = split(nvrs, a, "\n")
                for (i=1; i<=n; i++) if (a[i] != "") print "kernel-" a[i]
                print ""
                inserted=1
            }
            { print }
        ' "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    }
    echo "Appended new section to $HISTORY_FILE."
else
    echo "Patch application test failed. (Exit code: $TEST_RESULT)"
    if [ -s ../results/failed_tests.log ]; then
        echo "====================================="
        echo "Patch application failed for the following kernels/features:"
        cat ../results/failed_tests.log
        echo "====================================="
    fi
    echo "Please check manually using 'kernel-mock.sh -d' if necessary."
fi

exit $TEST_RESULT
