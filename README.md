# Linux kernel patches (compilable with the fedora kernel)
## Latest Build Status
|Copr Project Name|Copr Build Status|
|---|---|
|[kernel-tkg](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/package/kernel/status_image/last_build.png)|
|[kernel-tkg-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-preempt/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-preempt/package/kernel/status_image/last_build.png)|
|[kernel-tkg-zen2](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2/package/kernel/status_image/last_build.png)|
|[kernel-tkg-zen2-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt/package/kernel/status_image/last_build.png)|
|[kernel-tkg-icelake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt/package/kernel/status_image/last_build.png)|
|[kernel-tkg-alderlake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt/package/kernel/status_image/last_build.png)|
|[kernel-tkg-ivybridge-pds](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-ivybridge-pds/)|![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-ivybridge-pds/package/kernel/status_image/last_build.png) **Not supported since 6.6**|

## Overview
- You can create custom rpm with these patches for the fedora.
  - Download srpm from fedora repository and apply patches to the kernel source.
    - https://koji.fedoraproject.org/koji/packageinfo?packageID=8
  - Patched RPMs are available in [Copr](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) You can install by dnf.
- Most of these patches are suitable for gaming on Linux.
  - These patches are from:
   - https://github.com/graysky2/kernel_compiler_patch
   - https://github.com/Frogging-Family/community-patches
   - https://github.com/Frogging-Family/linux-tkg
   - https://github.com/zhmars/cjktty-patches

   (Some of them are modified from the original.)

   Note: All the Project C patches (0009-prjc_vx.x-rx.patch) are under the GNU GENERAL PUBLIC LICENSE Version 3

## How to install patched kernel RPM
Quick start.
```
sudo dnf copr whitehara/kernel-tkg
sudo dnf install kernel-6.4.14-200_tkg.fc38
```
See [Copr](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) for details.

If you want to try other custom kernels, you may also check my other projects.
- Tkg patches and preemptive kernel: [kernel-tkg-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-prempt)
- Tkg patches and AMD Zen2+ optimized kernel: [kernel-tkg-zen2](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2)
- Tkg patches, AMD Zen2+ optimized and preemptive kernel:  [kernel-tkg-zen2-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt)
- Tkg patches, Intel Ice Lake+ optimized and preemptive kernel:  [kernel-tkg-icelake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt)
- Tkg patches, Intel Alder Lake+ optimized and preemptive kernel:  [kernel-tkg-alderlake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt)
- Tkg patches, Intel IvyBridge+ optimized and pds kernel:  [kernel-tkg-ivybridge-pds](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-ivybridge-pds) **Not supported since 6.6**

Files in the kernel-local folder are used in these custom kernel projects.

## Tested version (Newest versions only)
**BEWARE: "tested" means just "compilable", it does not mean "It completely works for your environment". Please use it at your own risk.**
- 6.12 patches
  -  [kernel-6.12.7-200.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2606806)
  -  [kernel-6.12.7-100.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2606805)
- 6.11 patches
  -  [kernel-6.11.11-300.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2597312)
  -  [kernel-6.11.11-200.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2597311)
  -  [kernel-6.11.9-100.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2585691)
- 6.10 patches
  -  [kernel-6.10.14-200.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2566685)
  -  [kernel-6.10.14-100.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2566684)
- 6.9 patches
  -  [kernel-6.9.12-200.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2517792)
  -  [kernel-6.9.12-100.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2517794)
- 6.8 patches
  -  [kernel-6.8.12-300.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2458998) *Since 6.8.10, WINSYNC is replaced to NTSYNC.*
  -  [kernel-6.8.12-200.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2458999) *Since 6.8.10, WINSYNC is replaced to NTSYNC.*
  -  [kernel-6.8.10-100.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2453005) *Since 6.8.10, WINSYNC is replaced to NTSYNC.*
- 6.7 patches
  -  [kernel-6.7.12-200.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2431044) *Since this version, bcachefs is merged into the kernel mainline. BBRv2 is removed.*
  -  [kernel-6.7.12-100.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2431066) *Since this version, bcachefs is merged into the kernel mainline. BBRv2 is removed.*
- 6.6 patches
  -  [kernel-6.6.14-200.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2386947) *Since this version, The default CPU scheduler is changed to EEVDF.*
  -  [kernel-6.6.14-100.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2386940) *Since this version, The default CPU scheduler is changed to EEVDF.*
- 6.5 patches
  -  [kernel-6.5.12-300.fc39](https://koji.fedoraproject.org/koji/buildinfo?buildID=2322803)
  -  [kernel-6.5.12-200.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2322801)
  -  [kernel-6.5.13-100.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2325633)
- 6.4 patches
  -  [kernel-6.4.16-200.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2289005)
  -  [kernel-6.4.16-100.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2289004)
- 6.3 patches
  -  [kernel-6.3.13-200.fc38](https://koji.fedoraproject.org/koji/buildinfo?buildID=2231054) *Since this version, CONFIG_MLX5_CORE is not enabled for preventing a BUG.*
  -  [kernel-6.3.13-100.fc37](https://koji.fedoraproject.org/koji/buildinfo?buildID=2231053) *Since this version, CONFIG_MLX5_CORE is not enabled for preventing a BUG.*
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

There are 2 ways. One is build with the script in "build-script" dir, another is without the script. 
###  Build with the script
In build-script dir, you see "kernel-mock.sh". This script is used for building my projects, you can use and modify as you like.

#### Preparation
- Install mock, copr-cli, koji.

      dnf install mock copr-cli koji

- Modify "support-vers". It contains Original fedora project kernel versions for building.
If you want to build new versions, you need to add it to this file. 
- Modify "support-features". It contains Project ID for copr, Custom tag for the package name, Features like bmq,pds,cpu-arch which are used in spec-mod.sh


**Each features are built with all versions. E.g. If you have 3 features and 2 versions, Results wll be 3 projects and each projects have 2 versions.**

**If you want to add CPU-arch, you also need to add kernel-local.CPU-arch files.**

#### Run script
In build-script dir, you can run like below:

     ./kernel-mock.sh

It builds rpms on your local machine's [mock](https://github.com/rpm-software-management/mock) environment, then copy results from the mock environment to "../results" dir.

If you want to see detail messages and run rpmbuild commands by yourself in the mock environment,

     ./kernel-moch.sh -d

This will extract your package and stop when patches are applied, then open the mock's shell. So you can check the patches are applied correctly or not, modify patches if you need, then run "rpmbuild" manually. In this mode, only first line of support-vers, support-features are used. And **Your results are not moved to reults dir. Please move it manually before you exit this mode's shell.**

If you want to build on Copr,

    ./kernel-mock.sh -c

You must setup your copr account and make projects before you run.

### Build without the script
#### Setup rpm build tree
If you aleady have one, you can skip this step.

      dnf install rpmdevtools
      rpmdev-setuptree
The rpmdev-setuptree command creates build tree automaticaly.
You can check where it is like this.

      rpmbuild --showrc | grep _topdir
In this document, the _topdir is just "rpm".
#### Download source kernel-*.fc*.srpm

      dnf download --source kernel
If you want to use the newest developing kernel, you can use koji.

      koji download-build -a src kernel-*

#### Extract source to rpm build tree

      rpm -Uvh kernel-*.fc*.srpm

#### Clone repository to local folder

      mkdir kernel-patch-fedora && cd kernel-patch-fedora
      git clone https://github.com/whitehara/kernel-patch-fedora.git .

#### Copy files to SOURCES directory

      cp kernel-patch-fedora/5.16/* rpm/SOURCES/

#### Modify kernel config
The config-path.sh adds minimal config into .config files.
If you want to custom your kernel, you can add kerne-local file in SOURCES directory.

      cd rpm/SOURCES &&  ./config-patch.sh
#### Modify kernel.spec(add these patch lines like below)
The _custom_kernel_tag is suffix for kernel package name. It looks like "kernel-version_custom_kernel_tag.fc35.x86_64.rpm"

      cd rpm/SOURCES && ./spec-mod.sh _custom_kernel_tag

You can use other options like below:

      ./spec-mod.sh <CUSTOM TAG> [cfs|pds|bmq]
      CUSTOMTAG: Add CUSTOM TAG for the package
      cfs|pds|bmq: Select scheduler for Project-C patch

#### Check if paches are appliciable.

      rpmbuild -bp kernel.spec

"-bp" option means doing until applying patches(does not doing compile).

#### Compile

      rpmbild -bb kernel.spec
"-bb" is just compile binary only. If you want the srpm, use "-ba"(with binary) or "-bs"(without binary) option. See manpages of rpmbuild to find the other rpmbuild option.

You can also use options like "--without debug --without debuginfo". Creating debug rpms needs the longer time to compile. So if you don't need them, I recommend to set these options. See kernel.spec file to find the other "--without" option. **You may need to add "--without configchecks" to avoid config check errors since 6.0.**
#### Install
      cd rpm/RPMS/
      dnf install kernel-*
