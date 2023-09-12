#!/bin/sh

# Usage:
# ./spec-mod.sh <CUSTOM TAG> [cfs|pds|bmq]
#   CUSTOMTAG: Add CUSTOM TAG for the package
#  cfs|pds|bmq: Select scheduler for Project-C patch

BASEVERSION=6.5
PRJC_RELEASE=0
SPEC=kernel.spec
CUSTOMTAG=$1
SCHED=$2

if [ -z $SCHED ]; then
	# Default scheduler is "bmq"
	SCHED="bmq"
fi
# add custom tag
if [ -n $CUSTOMTAG ]; then
    sed -i -e "s/^# define buildid .local$/%define buildid $CUSTOMTAG/g" $SPEC
fi

patch_insert () {
	PATCHLINE="Patch$1: $2"
	PATCH=$2
	sed -i -e "/^Patch[0-9]*: linux-kernel-test.patch/i $PATCHLINE" \
	       -e "/^ApplyOptionalPatch linux-kernel-test.patch/i ApplyOptionalPatch $PATCH" \
	       $SPEC
}

# add paches to spec file
patch_insert "8001" "more-uarches-for-kernel-5.17p.patch"
patch_insert "9000" "0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch"
#patch_insert "9001" "0001-mm-Support-soft-dirty-flag-reset-for-VA-range.patch"
patch_insert "9002" "0002-clear-patches.patch"
#patch_insert "9003" "0002-mm-Support-soft-dirty-flag-read-with-reset.patch"
patch_insert "9004" "0003-glitched-base.patch"
[ $SCHED = "cfs" ] && patch_insert "9005" "0003-glitched-cfs.patch" && \
	patch_insert "9006" "0003-glitched-cfs-additions.patch"
[ $SCHED = "pds" ] && patch_insert "9005" "0005-glitched-pds.patch"
[ $SCHED = "bmq" ] && patch_insert "9005" "0009-glitched-bmq.patch" && \
	patch_insert "9006" "0009-glitched-ondemand-bmq.patch"
patch_insert "9007" "0006-add-acs-overrides_iommu.patch"
patch_insert "9009" "0007-v$BASEVERSION-fsync1_via_futex_waitv.patch"
patch_insert "9010" "0007-v$BASEVERSION-winesync.patch"
patch_insert "9011" "0008-$BASEVERSION-bcachefs.patch"
patch_insert "9012" "0009-prjc_v$BASEVERSION-r$PRJC_RELEASE.patch"
patch_insert "9014" "0012-misc-additions.patch"
patch_insert "9015" "0013-fedora-rpm.patch"
patch_insert "9016" "0013-optimize_harder_O3.patch"
patch_insert "9017" "0013-suse-additions.patch"
patch_insert "9050" "BBRv2.mypatch"
patch_insert "9051" "OpenRGB.mypatch"
patch_insert "9052" "cjktty-$BASEVERSION.patch"
patch_insert "9053" "cjktty-add-cjk32x32-font-data.patch"
patch_insert "9099" "0099-fix-confdata.patch"
