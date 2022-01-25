#!/bin/sh

BASEVERSION=5.15
SPEC=kernel.spec
CUSTOMTAG=$1

# add custom tag
if [ -n $CUSTOMTAG ]; then
    sed -e "s/^# define buildid .local$/%define buildid $CUSTOMTAG/g" $SPEC > $SPEC.new
    mv $SPEC $SPEC.old
    mv $SPEC.new $SPEC
fi

patch_insert () {
	PATCHLINE="Patch$1: $2"
	PATCH=$2
	sed -e "/^Patch[0-9]*: linux-kernel-test.patch/i $PATCHLINE" $SPEC > $SPEC.new
	sed -e "/^ApplyOptionalPatch linux-kernel-test.patch/i ApplyOptionalPatch $PATCH" $SPEC.new > $SPEC
}

# add paches to spec file
patch_insert "8001" "more-uarches-for-kernel-5.15p.patch"
patch_insert "9000" "0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch"
patch_insert "9001" "0001-mm-Support-soft-dirty-flag-reset-for-VA-range.patch"
patch_insert "9002" "0002-clear-patches.patch"
patch_insert "9003" "0002-mm-Support-soft-dirty-flag-read-with-reset.patch"
patch_insert "9004" "0003-glitched-base.patch"
patch_insert "9005" "0003-glitched-cfs.patch"
patch_insert "9007" "0006-add-acs-overrides_iommu.patch"
patch_insert "9008" "0007-v$BASEVERSION-fsync.patch"
patch_insert "9010" "0007-v$BASEVERSION-winesync.patch"
patch_insert "9012" "prjc_v$BASEVERSION-r1.patch"
patch_insert "9013" "0012-misc-additions.patch"