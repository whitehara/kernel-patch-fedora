#!/bin/sh

# Usage:
# ./spec-mod.sh <CUSTOM TAG> [cfs|eevdf]
#   CUSTOMTAG: Add CUSTOM TAG for the package
#  cfs|eevdf|bmq|pds: Select CPU scheduler

BASEVERSION=6.8
PRJC_RELEASE=1
SPEC=kernel.spec
CUSTOMTAG=$1
SCHED=$2

if [ -z $SCHED ]; then
	# Default scheduler is "eevdf"
	SCHED="eevdf"
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
patch_insert "8001" "more-uarches-for-kernel-6.8-rc4p.patch"
patch_insert "9000" "0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch"
patch_insert "9002" "0002-clear-patches.patch"
patch_insert "9004" "0003-glitched-base.patch"
[ $SCHED = "cfs" ] && patch_insert "9005" "0003-glitched-cfs.patch" && \
	patch_insert "9006" "0003-glitched-cfs-additions.patch"
[ $SCHED = "eevdf" ] && patch_insert "9005" "0003-glitched-cfs.patch" && \
    patch_insert "9006" "0003-glitched-eevdf-additions.patch"
patch_insert "9007" "0006-add-acs-overrides_iommu.patch"
patch_insert "9009" "0007-v$BASEVERSION-fsync1_via_futex_waitv.patch"
patch_insert "9010" "0007-v$BASEVERSION-winesync.patch"
[ $SCHED != "eevdf" ] && patch_insert "9012" "0009-prjc_v$BASEVERSION-r$PRJC_RELEASE.patch"
patch_insert "9014" "0012-misc-additions.patch"
patch_insert "9015" "0013-fedora-rpm.patch"
patch_insert "9016" "0013-optimize_harder_O3.patch"
patch_insert "9051" "0014-OpenRGB.patch"
patch_insert "9052" "cjktty-$BASEVERSION.patch"
patch_insert "9053" "cjktty-add-cjk32x32-font-data.patch"
patch_insert "9099" "0099-fix-confdata.patch"
