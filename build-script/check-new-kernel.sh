#!/bin/bash

# Move to the script's directory
cd "$(dirname "$0")"

STATE_FILE="../results/.last_tested_kernel_base"

echo "Checking for the latest kernel builds on Fedora Koji..."

# Identify the base version of the latest completed kernel build (excluding rc)
LATEST_NVR=$(koji list-builds --package=kernel --state=COMPLETE --quiet | awk '{print $1}' | grep '^kernel-' | grep -v '\.rc' | tail -n 1)

if [ -z "$LATEST_NVR" ]; then
    echo "Error: Failed to retrieve the latest kernel information from Koji."
    exit 1
fi

# Example: Extract 6.19.9 from kernel-6.19.9-200.fc43
BASE_VER=$(echo "$LATEST_NVR" | sed -E 's/^kernel-([^-]+)-.*/\1/')

LAST_TESTED=""
if [ -f "$STATE_FILE" ]; then
    LAST_TESTED=$(cat "$STATE_FILE")
fi

if [ "$BASE_VER" == "$LAST_TESTED" ]; then
    echo "The latest kernel ($BASE_VER base) has already been tested."
    exit 0
fi

echo "New kernel detected: $BASE_VER"
echo "Fetching builds for all associated fc versions..."

# Retrieve all build varieties that match the base version
NEW_BUILDS=$(koji list-builds --package=kernel --state=COMPLETE --quiet | awk '{print $1}' | grep "^kernel-${BASE_VER}-" | grep -v '\.rc' | sed 's/^kernel-//')

if [ -z "$NEW_BUILDS" ]; then
    echo "Error: No new kernel builds found."
    exit 1
fi

echo "Retrieved kernel builds:"
echo "$NEW_BUILDS"

# Backup support-vers
cp support-vers support-vers.bak

# Create a temporary file to prepend the new builds
echo "$NEW_BUILDS" > support-vers.tmp

# Append old support-vers, excluding the newly added builds
while read -r OLD_VER; do
    # Keep comments or blank lines, but exclude duplicate versions
    if [ -n "$OLD_VER" ] && echo "$NEW_BUILDS" | grep -qx "$OLD_VER"; then
        continue
    fi
    echo "$OLD_VER" >> support-vers.tmp
done < support-vers.bak

mv support-vers.tmp support-vers
echo "Updated support-vers. Starting tests..."

# Clear the previous test failure log
rm -f ../results/failed_tests.log

# Execute with -t option (tests patch application only, returns success/failure as exit status)
./kernel-mock.sh -t
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "All patch application tests succeeded."
    # Record the base version only if tests succeed
    echo "$BASE_VER" > "$STATE_FILE"
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
