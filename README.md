# kernel patches which can compile with fedora kernel
## Overview
- You can create custom rpm from fedora custom kernel.
- Download srpm from fedora repository and modify kernel.
- Most of these patches are from https://github.com/Frogging-Family/linux-tkg
## How to use
- Download source kernel-*.fc*.srpm

      dnf download --source kernel
      or
      koji download-build -a src kernel-*

- Extract source to somewhere

      rpm -Uvh kernel-*.fc*.srpm

- Clone repository to local folder

      mkdir kernel-patch-fedora && cd kernel-patch-fedora
      git clone https://github.com/whitehara/kernel-patch-fedora .

- Copy files to SOURCES directory

      cp kernel-patch-fedora/5.16/* /tmp/rpm/SOURCES/

- Modify kernel config ( You can modify config-patch.sh if you want to custom your kernel. )

      cd /tmp/rpm/SOURCES &&  ./config-patch.sh

- Modify kernel.spec(add these patch lines like below)

      vi /tmp/rpm/SPEC/kernel.spec

      # recommend to modify .buildid tag
      %define buildid _CUSTOM

      # Add these lines before END OF PATCH DEFINITIONS
      Patch8001:more-uarches-for-kernel-5.15p.patch
      Patch9000:0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch
      Patch9001:0001-mm-Support-soft-dirty-flag-reset-for-VA-range.patch
      Patch9002:0002-clear-patches.patch
      Patch9003:0002-mm-Support-soft-dirty-flag-read-with-reset.patch
      Patch9004:0003-glitched-base.patch
      Patch9005:0003-glitched-cfs.patch
      Patch9006:0003-glitched-cfs-additions.patch
      Patch9007:0006-add-acs-overrides_iommu.patch
      Patch9008:0007-v5.16-fsync.patch
      Patch9009:0007-v5.16-fsync1_via_futex_waitv.patch
      Patch9010:0007-v5.16-winesync.patch
      Patch9011:0009-glitched-bmq.patch
      Patch9012:0009-prjc_v5.16-r0.patch
      Patch9013:0012-misc-additions.patch

      # Add these lines before END OF PATCH APPLICATIONS
      ApplyOptionalPatch more-uarches-for-kernel-5.15p.patch
      ApplyOptionalPatch 0001-add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by.patch
      ApplyOptionalPatch 0001-mm-Support-soft-dirty-flag-reset-for-VA-range.patch
      ApplyOptionalPatch 0002-clear-patches.patch
      ApplyOptionalPatch 0002-mm-Support-soft-dirty-flag-read-with-reset.patch
      ApplyOptionalPatch 0003-glitched-base.patch
      ApplyOptionalPatch 0003-glitched-cfs.patch
      ApplyOptionalPatch 0003-glitched-cfs-additions.patch
      ApplyOptionalPatch 0006-add-acs-overrides_iommu.patch
      ApplyOptionalPatch 0007-v5.16-fsync.patch
      ApplyOptionalPatch 0007-v5.16-fsync1_via_futex_waitv.patch
      ApplyOptionalPatch 0007-v5.16-winesync.patch
      ApplyOptionalPatch 0009-glitched-bmq.patch
      ApplyOptionalPatch 0009-prjc_v$BASEVERSION-r0.patch
      ApplyOptionalPatch 0012-misc-additions.patch

- check

      rpmbuild -bp kernel.spec

- compile

      rpmbild -bb kernel.spec