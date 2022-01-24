# kernel patches which can compile with fedora kernel
## Overview
- You can create custom rpm from fedora custom kernel.
- Download srpm from fedora repository and modify kernel.
- These patches are from https://github.com/Frogging-Family/linux-tkg and https://github.com/graysky2/kernel_compiler_patch
- 5.15 patches are tested with fedora [kernel-5.15.16-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1887371)
- 5.16 patches are tested with fedora [kernel-5.16.2-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1888031)
## Setup rpm build tree
If you aleady have one, you can skip this step.

      dnf install rpmdevtools
      rpmdev-setuptree
The rpmdev-setuptree command creates build tree automaticaly.
You can check where it is like this.

      rpmbuild --showrc | grep _topdir
## How to use
### Download source kernel-*.fc*.srpm

      dnf download --source kernel
If you want to use the newest developing kernel, you can use koji.

      koji download-build -a src kernel-*

### Extract source to rpm build tree

      rpm -Uvh kernel-*.fc*.srpm

### Clone repository to local folder

      mkdir kernel-patch-fedora && cd kernel-patch-fedora
      git clone https://github.com/whitehara/kernel-patch-fedora.git .

### Copy files to SOURCES directory

      cp kernel-patch-fedora/5.16/* rpm/SOURCES/

### Modify kernel config
The config-path.sh adds minimal config into .config files.
If you want to custom your kernel, you can add kerne-local file in SOURCES directory.

      cd rpm/SOURCES &&  ./config-patch.sh
### Modify kernel.spec(add these patch lines like below)
The _custom_kernel_tag is suffix for kernel package name. It looks like "kernel-version_custom_kernel_tag.fc35.x86_64.rpm"

      cd rpm/SOURCES && ./spec-mod.sh _custom_kernel_tag
### Check if paches are appliciable.

      rpmbuild -bp kernel.spec

### Compile

      rpmbild -bb kernel.spec
### Install
      cd RPMS/
      dnf install kernel-*
