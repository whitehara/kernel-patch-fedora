# Linux kernel patches (compilable with the fedora kernel)
## Overview
- You can create custom rpm from the fedora kernel.
- Download srpm from fedora repository and apply patches to the kernel source.
- These patches are from https://github.com/graysky2/kernel_compiler_patch and https://github.com/Frogging-Family/linux-tkg (some of them are little modified from linux-tkg.)

## Tested version
"test" means just "compilable"
- 5.15 patches
  -  prjc patch changed since 5.15.17. See this [commit](https://github.com/whitehara/kernel-patch-fedora/commit/70d3603eac1756d536b83e35c9ae9e9c26e4d509).
  -  [kernel-5.15.17-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1909364)
  -  [kernel-5.15.18-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1909970)
- 5.16 patches
  -  prjc patch changed since 5.16.13. See this [commit](https://github.com/whitehara/kernel-patch-fedora/commit/95532792ce4546d5e7721f5cea152df90f55692b)
  -  [kernel-5.16.13-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1931130)
  -  [kernel-5.16.14-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1932632)
  -  [kernel-5.16.15-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1934820)
  -  [kernel-5.16.16-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1936201)
  -  [kernel-5.16.17-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1937906)
  -  [kernel-5.16.18-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1939738)
## Setup rpm build tree
If you aleady have one, you can skip this step.

      dnf install rpmdevtools
      rpmdev-setuptree
The rpmdev-setuptree command creates build tree automaticaly.
You can check where it is like this.

      rpmbuild --showrc | grep _topdir
In this document, the _topdir is just "rpm".
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

"-bp" option means doing until applying patches(does not doing compile).

### Compile

      rpmbild -bb kernel.spec
"-bb" is just compile binary only. If you want the srpm, use "-ba"(with binary) or "-bs"(without binary) option. See manpages of rpmbuild to find the other rpmbuild option.

You can also use options like "--without debug --without debuginfo". Creating debug rpms needs the longer time to compile. So if you don't need them, I recommend to set these options. See kernel.spec file to find the other "--without" option.
### Install
      cd rpm/RPMS/
      dnf install kernel-*
