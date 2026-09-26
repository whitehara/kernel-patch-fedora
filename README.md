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

- 7.2 patches
  -  [kernel-7.2.0-61.fc45](https://koji.fedoraproject.org/koji/buildinfo?buildID=3081939)
- 7.1 patches
  -  [kernel-7.1.1-300.fc44](https://koji.fedoraproject.org/koji/buildinfo?buildID=3020935)

<details>
<summary><b>Show older tested versions (Click to expand)</b></summary>

- 7.0 patches
  -  [kernel-7.0.13-200.fc44](https://koji.fedoraproject.org/koji/buildinfo?buildID=3020110)
  -  [kernel-7.0.13-100.fc43](https://koji.fedoraproject.org/koji/buildinfo?buildID=3020109)

- 6.19 patches
  -  [kernel-6.19.14-108.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=3000628)
- 6.18 patches
  -  [kernel-6.18.16-200.fc43](https://koji.fedoraproject.org/koji/buildinfo?buildID=2949513)
  -  [kernel-6.18.16-100.fc42](https://koji.fedoraproject.org/koji/buildinfo?buildID=2951827)
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

## Automatic check for new Fedora kernels (optional)
`build-script/auto-check.sh` watches Fedora Koji for new kernel builds and tests whether the patches still apply to them. It only **tests and reports**: it never edits `HISTORY.md`, commits, tags or pushes. Releasing stays a manual decision.

How it works:
1. `build-script/koji-candidates.sh` asks Koji once for the latest builds of each series directory (e.g. `7.2/`) and lists the NVRs that are not yet in `HISTORY.md`. Old builds that only happen to match a series prefix are excluded.
2. Each new NVR is tested with `kernel-mock.sh -t` (patch application only) in a **separate git worktree** created from your local `main`, so your working tree and `HEAD` are never touched. Only committed content is tested.
3. Results are appended to `results/autocheck/state.tsv` (one line per event: `testing` / `passed` / `failed` / `error` / `aborted` / `reset`), and a summary is written to `results/autocheck/last-run.txt`. Logs are kept in `results/autocheck/runs/<RUNID>/` (the latest 30 runs).
4. A `passed` NVR is not tested again. A `failed` NVR is tested again only after `main` changes (e.g. after you fix a patch).

```bash
./build-script/auto-check.sh --dry-run        # show what would be tested, without running mock
./build-script/auto-check.sh                  # check Koji and test new NVRs
./build-script/auto-check.sh --only 7.2.7-300.fc45   # test one NVR, ignoring the state
./build-script/auto-check.sh --forget 7.2.7-300.fc45 # treat one NVR as untested again
```

Exit codes: `0` nothing new / all passed, `1` some patches failed, `2` Koji or infrastructure error, `3` busy (another run or a manual `mock` is running) or deferred.

**Warning:** a test takes hours (about 2 hours per NVR) and puts heavy load on the disk (8 parallel `mock` chroots). It refuses to run (exit code `3`) while another `kernel-mock.sh`, `mock`, `auto-check.sh` or `check-new-kernel.sh` is running, because `mock` chroots are shared. Do not start `kernel-mock.sh` by hand while it is running.

### Run it once a day with a systemd user timer
Create these two files in `~/.config/systemd/user/` (replace `<repo>` with your clone's path):

`kernel-autocheck.service`
```ini
[Service]
Type=oneshot
ExecStart=<repo>/build-script/auto-check.sh
Nice=19
IOSchedulingClass=idle
TimeoutStartSec=12h
KillMode=mixed
SuccessExitStatus=1 3
```

`kernel-autocheck.timer`
```ini
[Timer]
OnCalendar=*-*-* 03:30:00
RandomizedDelaySec=30min
Persistent=false

[Install]
WantedBy=timers.target
```

```bash
systemd-analyze --user verify kernel-autocheck.service kernel-autocheck.timer
systemctl --user enable --now kernel-autocheck.timer
```

- `SuccessExitStatus=1 3` keeps "patches failed" and "busy" from marking the unit as failed; only exit code `2` does.
- A user timer only fires while you are logged in. To run it while logged out, run `sudo loginctl enable-linger $USER` once.
- `mock` must run without a terminal. The user needs to be in the `mock` group; check with a manual `systemctl --user start kernel-autocheck.service`.
- `Persistent=false` avoids starting a multi-hour test right after logging in when a run was missed.
- If a run is killed (e.g. by the 12 hour timeout), leftover `mock` chroots can remain. `kernel-mock.sh` creates one chroot per feature with `--uniqueext=<Project ID>` (the first column of `support-features`, e.g. `-tkg`), so the chroot names look like `fedora-<N>-x86_64--tkg`. List them in mock's base directory (`/var/lib/mock` by default) and clean each one, including the same `--uniqueext`:
  ```bash
  mock -r fedora-<N>-x86_64 --uniqueext=-tkg --scrub=all
  ```

### Notifications (optional)
`results/autocheck/last-run.txt` is always updated. To also get a Discord message, put the webhook URL in `~/.config/kernel-autocheck/env` (`chmod 600`):
```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```
It is only read by `auto-check.sh` and is never printed or passed on a command line. Messages are sent when a test starts and when it ends (passed / failed / error / aborted / deferred / Koji error), and when an NVR was aborted twice in a row and needs your attention. Nothing is sent when nothing is new.
