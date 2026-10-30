# Debian Trixie + Astroberry OS amd64 smoke-test ISO

A Debian 13 (Trixie) amd64 live/install ISO with [Astroberry OS](https://github.com/gordtulloch/astroberry-os)
installed from Astroberry's own signed APT repository (`https://astroberry.io/debian`,
`trixie`, `main`). It does **not** contain Galileo yet; it is the base the Galileo
layer will be installed onto (see [docs/PSD.md](../../docs/PSD.md)). It replaces
the superseded [`../amd64-test/`](../amd64-test/) image, which compiled INDI and
PHD2 itself.

## What is in it

Astroberry's packages are installed unmodified, the way its documentation
describes (repository + signing key + APT pin, then `apt install`). The build
refuses to continue unless the downloaded repository key has the fingerprint
documented in Astroberry's `docs/ARCHITECTURE.md`.

- **Astroberry:** `astroberry-manager`, `astroberry-os-sysmod` (hotspot, remote
  desktop, file sharing, Caddy), `indi-3rdparty-drivers` (and INDI 2.2.1), `gsc`,
  `phd2`, `phdlogview`, `astrometry.net`, `astap`, Siril, GPredict, SER Player,
  the Xfce desktop, plus OpenSSH.
- **Not included, deliberately:**
  - **KStars/EKOS** is not required. `astroberry-os` has a hard dependency on
    `kstars-bleeding`, so the meta-package is not installed; instead the packages
    it depends on are listed in
    [`config/package-lists/astroberry.list.chroot`](config/package-lists/astroberry.list.chroot)
    without it. That list is copied from `astroberry-os` 3.2 and must be refreshed
    when Astroberry changes the meta-package (`apt-cache depends astroberry-os`).
  - **FireCapture, AstroDMx, CCDciel** are third-party binaries in Astroberry's
    `restricted` component, which the documented `main`-only setup does not enable.
  - **brltty** is checked in the build hook and the ISO validation.
- **live-build's automatic firmware list is turned off** (`--firmware-chroot false`)
  because it adds every package tagged as firmware, including `indi-dsi`, which
  conflicts with Astroberry's `indi-3rdparty-drivers`. Common Wi-Fi firmware and
  CPU microcode are listed explicitly instead.

## Build with Docker

Docker Desktop must be running with at least 8 GB of memory, the host needs
network access and about 20 GB free disk. From the project root in PowerShell:

```powershell
.\images\astroberry-test\build-iso.ps1
```

The build installs about 750 packages and takes roughly 15–30 minutes. The ISO
and a SHA-256 file are written to `dist/`:
`debian-trixie-astroberry-amd64-smoke-<YYYYMMDD>.iso`.

The build runs two checks. A chroot hook
([`0990-check-astroberry-image.chroot`](config/hooks/normal/0990-check-astroberry-image.chroot))
fails if required Astroberry packages are missing or did not come from
astroberry.io, if KStars is present, or if INDI or PHD2 have unresolved
libraries. [`validate-iso.sh`](validate-iso.sh) then checks the El Torito boot
catalog and the ISO's package manifest.

## Status

**The configuration in this directory is ahead of the ISO in `dist/`.**

- **Built and checked (2026-10-30):** the first ISO,
  `dist/debian-trixie-astroberry-amd64-smoke-20261030.iso`, built and passed both
  checks. It boots as a Live CD in VirtualBox (reported by the project owner), but it
  has **no installer** (it was built with `--debian-installer live`, which produced no
  installer files, and the boot menu has only "Live system" entries) and it **shows the
  boot menu** before starting.
- **Changed but not built:** the configuration now adds the Calamares installer
  (an "Install Debian" icon on the live desktop, plus the GRUB packages it needs),
  sets `--debian-installer none`, and patches the BIOS (isolinux) and UEFI (GRUB)
  boot menus to start the Live system immediately. `validate-iso.sh` and the chroot
  hook check for these. A rebuild was started and **deliberately stopped**, so none
  of it has been built, validated, or booted. The chosen direction is: boot straight
  into the Live system, with install-to-disk available from the live desktop but not
  required.
- **Not verified at all:** that Astroberry's services start, that the web interface
  or hotspot work, that the remote desktop is reachable, or that Calamares can install.
  Several Astroberry postinstall steps ran in a chroot without a running system, so
  first-boot behaviour (cloud-init, hostname, user account, display manager under live
  boot) needs the VirtualBox check below.

To pick this up, run `.\images\astroberry-test\build-iso.ps1` (15–30 minutes) and
then the checklist below. Because the boot menu is bypassed, fail-safe mode is not
offered at boot; if a boot problem needs it, remove the `config/bootloaders` patching
in `build-iso.sh`.

## VirtualBox validation (not yet done)

1. New Linux/Debian 64-bit VM, 4 GB RAM (2 GB minimum), 20 GB disk, NAT with DHCP.
2. Boot the ISO. It should start the Live system without stopping at a boot menu
   (rebuilt image only). Check it reaches a desktop and gets an address, and that the
   "Install Debian" icon is on the desktop.
3. Check which Astroberry services start (`systemctl --failed`), whether
   Astroberry Manager answers (try ports 80/443 via Caddy), and whether
   `indiserver` and `phd2` start. Record the actual hostname, ports, accounts and
   passwords: these are open facts in the PSD.
4. Optional: run Calamares from the live desktop to install to the virtual disk,
   reboot without the ISO, repeat 3. The installer shows Debian branding.
5. `dpkg-query -W brltty kstars-bleeding` should report neither installed.

The live account is live-build's default and SSH is enabled: use this image only
on an isolated network.
