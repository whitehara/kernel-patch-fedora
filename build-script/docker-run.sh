#!/bin/bash
# This script is used to run the kernel-mock.sh script inside a Fedora docker container expecially for Github Actions.
# It installs necessary packages, runs the build, and handles the results.

# Usage: ./docker-run.sh

# Make sure to mount Github Repository to /build and set up the copr config file at /build/copr before running this script.

echo "Check files"
if [ ! -f /build/copr ]
then
    echo "Copr config file not found at /build/copr. Please set up the copr config file before running this script."
    exit 1
fi
if [ ! -f /build/build-script/kernel-mock.sh ]
then
    echo "Build script not found at /build/build-script/kernel-mock.sh. Please mount the Github Repository to /build before running this script."
    exit 1
fi

echo "Install packages"
dnf -q -y install koji copr-cli mock gawk

echo "Run build"
cd /build/build-script
./kernel-mock.sh -c -f /build/copr
if [ $? -ne 0 ]
then
    echo "Build failed, Cancel all running builds on copr"
    ./kernel-mock.sh -n
    exit 1
else
    echo "Wait 180s for starting the builds on copr"
    sleep 180s
    echo "Write BUILD.md"
    ./build-status.sh -f /build/copr > /build/results/BUILD.md
fi
exit 0