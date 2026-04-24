# Linux kernel patches (compilable with the Fedora kernel)

## Overview
You can create custom RPMs with these patches for Fedora Linux. Most of these patches are **optimized for gaming on Linux**. 
You can install pre-patched RPMs directly from [Copr](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) using `dnf`, or download SRPMs from the Fedora repository and apply the patches to the kernel source yourself (e.g., from [Koji](https://koji.fedoraproject.org/koji/packageinfo?packageID=8)).

These patches are sourced and modified from:
- https://github.com/graysky2/kernel_compiler_patch
- https://github.com/Frogging-Family/community-patches
- https://github.com/Frogging-Family/linux-tkg
- https://github.com/bigshans/cjktty-patches
- https://github.com/CachyOS/kernel-patches
- https://lvra.gitlab.io/docs/hardware/

*(Note: All Project C patches (`0009-prjc_vx.x-rx.patch`) are under the GNU GENERAL PUBLIC LICENSE Version 3.)*

## Latest Build Status
| Copr Project Name | Copr Build Status |
|---|---|
| [kernel-tkg](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/package/kernel/status_image/last_build.png) |
| [kernel-tkg-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-preempt/package/kernel/status_image/last_build.png) |
| [kernel-tkg-zen2](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2/package/kernel/status_image/last_build.png) |
| [kernel-tkg-zen2-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt/package/kernel/status_image/last_build.png) |
| [kernel-cachyos-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-preempt/package/kernel/status_image/last_build.png) |
| [kernel-cachyos-zen2-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen2-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen2-preempt/package/kernel/status_image/last_build.png) |
| [kernel-cachyos-zen3-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen3-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen3-preempt/package/kernel/status_image/last_build.png) |
| [kernel-tkg-icelake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt/package/kernel/status_image/last_build.png) |
| [kernel-tkg-alderlake-preempt](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt/) | ![Status](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt/package/kernel/status_image/last_build.png) |

## How to install patched kernel RPM

### Quick Start
You can quickly install the patched kernel via Copr. See the [Copr Project](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg/) for more details.

```bash
sudo dnf copr enable whitehara/kernel-tkg
sudo dnf install kernel-6.4.14-200_tkg.fc38
```

### Other Custom Kernels
If you want to try other customized versions, check the table below and enable the desired Copr repository instead. *(Files in the `kernel-local` folder are used in these custom kernel projects.)*

#### Based on TKg Patches
| Project Name | Preemptive | Architecture Optimization | Copr Repository |
|---|:---:|:---:|---|
| **kernel-tkg** | - | - | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg) |
| **kernel-tkg-preempt** | ✅ | - | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-preempt) |
| **kernel-tkg-zen2** | - | AMD Zen2+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2) |
| **kernel-tkg-zen2-preempt** | ✅ | AMD Zen2+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-zen2-preempt) |
| **kernel-tkg-icelake-preempt** | ✅ | Intel Ice Lake+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-icelake-preempt) |
| **kernel-tkg-alderlake-preempt** | ✅ | Intel Alder Lake+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-tkg-alderlake-preempt) |

#### Based on CachyOS Patches
| Project Name | Preemptive | Architecture Optimization | Copr Repository |
|---|:---:|:---:|---|
| **kernel-cachyos-preempt** | ✅ | - | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-preempt) |
| **kernel-cachyos-zen2-preempt** | ✅ | AMD Zen2+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen2-preempt) |
| **kernel-cachyos-zen3-preempt** | ✅ | AMD Zen3+ | [Link](https://copr.fedorainfracloud.org/coprs/whitehara/kernel-cachyos-zen3-preempt) |

## Tested version (Latest versions only)
> **BEWARE:** "tested" means just **"compilable"**, it does not mean "It completely works for your environment". Please use it at your own risk.

- 6.19 patches
  -  [kernel-6.19.14-300.fc44](https://koji.fedoraproject.org/koji/buildinfo?buildID=2985672)
  -  [kernel-6.19.14-200.fc43](https://koji.fedoraproject.org/koji/buildinfo?buildID=2985726)
  -  [kernel-6.19.14-100.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2985718)
- 6.18 patches
  -  [kernel-6.18.16-200.fc43](https://koji.fedoraproject.org/koji/buildinfo?buildID=2949513)
  -  [kernel-6.18.16-100.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2951827)

<details>
<summary><b>Show older tested versions (Click to expand)</b></summary>

- 6.17 patches
  -  [kernel-6.17.13-300.fc43](https://koji.fedoraproject.org/koji/buildinfo?buildID=2881992)
  -  [kernel-6.17.13-200.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2881993)
  -  [kernel-6.17.10-100.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2871983)
- 6.16 patches
  -  [kernel-6.16.12-200.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2842343)
  -  [kernel-6.16.12-100.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2842346)
- 6.15 patches
  -  [kernel-6.15.11-200.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2804148)
  -  [kernel-6.15.11-100.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2804149)
- 6.14 patches
  -  [kernel-6.14.11-300.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2730240)
  -  [kernel-6.14.11-200.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2730239)
  -  [kernel-6.14.6-100.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2711919)
- 6.13 patches
  -  [kernel-6.13.12-200.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2702627)
  -  [kernel-6.13.12-100.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2702628)
- 6.12 patches
  -  [kernel-6.12.15-200.fc41](https://koji.fedoraproject.org/koji/buildinfo?buildID=2661636)
  -  [kernel-6.12.15-100.fc40](https://koji.fedoraproject.org/koji/buildinfo?buildID=2661635)
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

</details>

## How to build your custom kernel

There are two ways to build custom kernels manually. One is using the included script in the `build-script` directory, and the other is manually executing the build commands.

### Method 1: Build with the provided script
In the `build-script` directory, you will find `kernel-mock.sh`. This script is used for building my projects and you can use or modify it as you like.

#### 1. Preparation
Install `mock`, `copr-cli`, and `koji`:
```bash
sudo dnf install mock copr-cli koji
```

- **`support-vers`:** Modify this file to include the original Fedora project kernel versions you want to build. 
- **`support-features`:** Modify this file to configure Project ID for Copr, custom tags, and features like `bmq`, `pds`, or CPU architectures.

> **Note:** Each feature is built with all versions. E.g., if you have 3 features and 2 versions, the results will be 3 projects and each project will have 2 versions. If you add a CPU-arch, you also need to add corresponding `kernel-local.<CPU-arch>` files.

#### 2. Run the script
Run it locally:
```bash
./kernel-mock.sh
```
This builds RPMs on your local machine's `mock` environment, then copies results from the `mock` environment to the `../results` directory.

**Advanced Options:**
- **Debug Mode (Shell):** 
  ```bash
  ./kernel-mock.sh -d
  ```
  This will extract your package and stop when patches are applied, then open the mock's shell. You can check the patches and run `rpmbuild` manually. In this mode, only the first line of `support-vers` and `support-features` is used. **Your results are not moved to the `results` dir.**

- **Copr Mode (Build on Copr):**
  ```bash
  ./kernel-mock.sh -c
  ```
  You must set up your Copr account and create projects before you run this.

### Method 2: Build manually without the script

#### 1. Setup RPM build tree
*(Skip if you already have one)*
```bash
sudo dnf install rpmdevtools
rpmdev-setuptree
```
You can verify the directory path like this (we will refer to `_topdir` as `rpm` in this guide):
```bash
rpmbuild --showrc | grep _topdir
```

#### 2. Download the source
```bash
dnf download --source kernel
```
Or for the latest development kernel via Koji:
```bash
koji download-build -a src kernel-*
```

#### 3. Extract the source
```bash
rpm -Uvh kernel-*.fc*.srpm
```

#### 4. Clone the repository
```bash
mkdir kernel-patch-fedora
cd kernel-patch-fedora
git clone https://github.com/whitehara/kernel-patch-fedora.git .
```

#### 5. Apply files to SOURCES directory
```bash
cp kernel-patch-fedora/5.16/* ~/rpmbuild/SOURCES/
```
*(Replace `5.16` with your target version and `~/rpmbuild` with your actual build tree).*

#### 6. Modify the kernel config
The `config-path.sh` script adds minimal config into `.config` files. If you want to customize your kernel further, add a `kernel-local` file to the `SOURCES` directory.
```bash
cd ~/rpmbuild/SOURCES
./config-patch.sh
```

#### 7. Update kernel.spec
Add custom tags to the kernel spec file (e.g., `kernel-version_custom_kernel_tag.fc35.x86_64.rpm`):
```bash
cd ~/rpmbuild/SOURCES
./spec-mod.sh _custom_kernel_tag
```
Other options:
```bash
./spec-mod.sh <CUSTOM_TAG> [CPU arch] [eevdf|pds|bmq] [preempt]
```
- `<CUSTOM_TAG>`: Suffix for the package.
- `CPU arch`: CPU architecture to build for. Default is `X86_GENERIC`.
- `eevdf|pds|bmq`: Select scheduler for Project-C patch. Default is `eevdf`.
- `preempt`: Use preemptive mode. Default is non-preemptive.

See [support-features](build-script/support-features) for available options.

#### 8. Check if patches are applicable
```bash
rpmbuild -bp kernel.spec
```
> The `-bp` option applies patches but does not compile.

#### 9. Compile the RPM
```bash
rpmbuild -bb kernel.spec
```
> The `-bb` option compiles binary only. Use `-ba` for source + binary, or `-bs` for source SRPM only.

**Tip:** You can also use options like `--without debug --without debuginfo` to save compilation time. Since kernel *6.0*, you might also need `--without configchecks` to prevent config-check errors:
```bash
rpmbuild -bb kernel.spec --without debug --without debuginfo --without configchecks
```

#### 10. Install the compiled kernel
```bash
cd ~/rpmbuild/RPMS/x86_64/
sudo dnf install kernel-*
```
