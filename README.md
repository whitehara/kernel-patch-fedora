# kernel patches which can compile with fedora kernel
## Overview
- You can create custom rpm from fedora custom kernel.
- Download srpm from fedora repository and modify kernel.
- Most of these patches are from https://github.com/Frogging-Family/linux-tkg
## Setup rpm build tree
If you aleady have one, you can skip this step.

      dnf install rpmdevtools
      rpmdev-setuptree
The rpmdev-setuptree command setups build tree automaticaly.
You can check where it is like this.

      rpmbuild --showrc | grep _topdir
## How to use
### Download source kernel-*.fc*.srpm

      dnf download --source kernel
      or
      koji download-build -a src kernel-*

### Extract source to rpm build tree

      rpm -Uvh kernel-*.fc*.srpm

### Clone repository to local folder

      mkdir kernel-patch-fedora && cd kernel-patch-fedora
      git clone https://github.com/whitehara/kernel-patch-fedora .

### Copy files to SOURCES directory

      cp kernel-patch-fedora/5.16/* rpm/SOURCES/

### Modify kernel config ( You can modify config-patch.sh if you want to custom your kernel. )
**WARNING: original config-patch is optimized for AMD Zen2 architecture. you should change it.**

      cd rpm/SOURCES &&  ./config-patch.sh
### Modify kernel.spec(add these patch lines like below)
The _custom_kernel_tag is suffix for kernel package name. It looks like "kernel-vsersion_custom_kernel_tag.fc35.x86_64.rpm"

      cd rpm/SOURCES && ./spec-mod.sh _custom_kernel_tag
### Check if paches are appliciable.

      rpmbuild -bp kernel.spec

### Compile

      rpmbild -bb kernel.spec