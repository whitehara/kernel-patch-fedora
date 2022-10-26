# Linux kernel patches (compilable with the fedora kernel)
## Overview
- You can create custom rpm with these patches for the fedora.
  - Download srpm from fedora repository and apply patches to the kernel source.
- Most of these patches are suitable for gaming on Linux.
  - These patches are from https://github.com/graysky2/kernel_compiler_patch and https://github.com/Frogging-Family/linux-tkg (some of them are little modified from linux-tkg.)

## Tested version
"tested" means just "compilable", not means "It completely works for your environment"
- 6.0 patches
  -  [kernel-6.0.2-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2076408)
  -  [kernel-6.0.2-301.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2076935)
  -  [kernel-6.0.3-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2079222)
- 5.19 patches
  -  0009-prjc-v5.19-r0.patch is unstable ... Now it is changed to [torvic9's patch](https://gitlab.com/torvic9/linux519-vd/-/blob/master/prjc-519-r1-vd-test.patch)
  -  [kernel-5.19.14-200.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2071616)
- 5.18 patches
  -  0009-prjc-v5.18-r2.patch is modified since 5.18.18.
  -  [kernel-5.18.18-200.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2047494)
- 5.17 patches
  -  prjc patch changed since 5.17.2. See this [commit](https://github.com/whitehara/kernel-patch-fedora/commit/7d12a293c08f33ae931f88dfc7cd49019351baca)
  -  [kernel-5.17.2-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1944304)
  -  [kernel-5.17.4-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1953626)
  -  [kernel-5.17.5-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1957442) (Add Bluetooth fix)
  -  [kernel-5.17.6-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1964169) (Remove Bluetooth fix)
  -  [kernel-5.17.7-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1965517)
  -  [kernel-5.17.7-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1965519)
  -  [kernel-5.17.8-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1966665)
  -  [kernel-5.17.9-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1968153)
  -  [kernel-5.17.11-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1970749)
  -  [kernel-5.17.12-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1972299)
- 5.16 patches
  -  prjc patch changed since 5.16.19. See this [commit](https://github.com/whitehara/kernel-patch-fedora/commit/7d12a293c08f33ae931f88dfc7cd49019351baca)
  -  [kernel-5.16.19-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1944282)
  -  [kernel-5.16.20-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1948783)
- 5.15 patches
  -  prjc patch changed since 5.15.17. See this [commit](https://github.com/whitehara/kernel-patch-fedora/commit/70d3603eac1756d536b83e35c9ae9e9c26e4d509).
  -  [kernel-5.15.17-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1909364)
  -  [kernel-5.15.18-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1909970)
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
