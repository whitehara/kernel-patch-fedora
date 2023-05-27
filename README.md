# Linux kernel patches (compilable with the fedora kernel)
## Overview
- You can create custom rpm with these patches for the fedora.
  - Download srpm from fedora repository and apply patches to the kernel source.
    - https://koji.fedoraproject.org/koji/packageinfo?packageID=8
  - RPM is available in [Copr](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) You can install by dnf.
- Most of these patches are suitable for gaming on Linux.
  - These patches are from:
   - https://github.com/graysky2/kernel_compiler_patch
   - https://github.com/Frogging-Family/community-patches
   - https://github.com/Frogging-Family/linux-tkg

   (Some of them are modified from linux-tkg.)
## How to install patched kernel RPM
Quick start.
```
sudo dnf copr whitehara/kernel-tkg
sudo dnf install kernel-6.3.4-200_tkg.fc38
```
See [Copr](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) for details.

If you want to try other custom kernels, you may also check my other projects.
- Tkg patches and AMD Zen2+ optimized kernel: [kernel-tkg-zen2](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2)
- Tkg patches, AMD Zen2+ optimized and preemptive kernel:  [kernel-tkg-zen2-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt)
- Tkg patches, Intel Ice Lake+ optimized and preemptive kernel:  [kernel-tkg-ice-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-ice-preempt)
- Tkg patches, Intel Alder Lake+ optimized and preemptive kernel:  [kernel-tkg-alderlake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt)

Files in the kernel-local folder are used in these custom kernel projects.

## Tested version (Newest version only)
**BEWARE: "tested" means just "compilable", does not mean "It completely works for your environment". Please use it at your own risk.**
- 6.3 patches
  -  [kernel-6.3.4-200.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2205867) *CONFIG_MLX5_CORE is not enabled for preventing a BUG.*
  -  [kernel-6.3.4-100.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2205868) *CONFIG_MLX5_CORE is not enabled for preventing a BUG.*
- 6.2 patches
  -  [kernel-6.2.15-300.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2199143)
  -  [kernel-6.2.15-200.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2199132)
  -  [kernel-6.2.15-100.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2199134)
- 6.1 patches
  -  [kernel-6.1.18-200.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2168432)
- 6.0 patches
  -  [kernel-6.0.18-300.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2107932)
- 5.19 patches
  -  [kernel-5.19.14-200.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2071616)
- 5.18 patches
  -  [kernel-5.18.18-200.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=2047494)
- 5.17 patches
  -  [kernel-5.17.12-300.fc36](https://koji.fedoraproject.org/koji/buildinfo?buildID=1972299)
- 5.16 patches
  -  [kernel-5.16.20-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1948783)
- 5.15 patches
  -  [kernel-5.15.18-200.fc35](https://koji.fedoraproject.org/koji/buildinfo?buildID=1909970)
## How to build your custom kernel
### Setup rpm build tree
If you aleady have one, you can skip this step.

      dnf install rpmdevtools
      rpmdev-setuptree
The rpmdev-setuptree command creates build tree automaticaly.
You can check where it is like this.

      rpmbuild --showrc | grep _topdir
In this document, the _topdir is just "rpm".
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

You can also use options like "--without debug --without debuginfo". Creating debug rpms needs the longer time to compile. So if you don't need them, I recommend to set these options. See kernel.spec file to find the other "--without" option. **You may need to add "--without configchecks" to avoid config check errors since 6.0.**
### Install
      cd rpm/RPMS/
      dnf install kernel-*
