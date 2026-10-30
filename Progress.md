# Galileo on Astroberry — Progress

## Current direction

The project no longer builds its own operating system. Galileo is layered on
top of **Astroberry OS** ([astroberry-os](https://github.com/gordtulloch/astroberry-os),
[astroberry-manager](https://github.com/gordtulloch/astroberry-manager); both
GPL-3.0, as is Galileo) using the WebConnect plugin where appropriate, leaving
Astroberry code untouched, with the aim of contributing all Galileo functions
back to Astroberry. See [docs/PSD.md](docs/PSD.md) (rewritten for this
direction) for scope and open decisions.

## Status

- Documentation (README, CLAUDE.md, PSD, this file) revised for the new
  direction.
- **Base image built:** `dist/debian-trixie-astroberry-amd64-smoke-20261030.iso`
  (2.5 GB, sha256 `6ca6da44c7c567994d831bd2a544f13c9eca07939c4a3ea0f557e2e2e8bda9a1`)
  from [`images/astroberry-test/`](images/astroberry-test/). Debian 13 Trixie
  with Astroberry OS 3.2 packages from astroberry.io (astroberry-manager 1.2,
  astroberry-os-sysmod 3.2, INDI 2.2.1, PHD2 2.6.14), no KStars. The build hook and
  `validate-iso.sh` passed (packages from astroberry.io, no KStars, no brltty,
  boot catalog present). **Not booted** — see its README for the VirtualBox
  checklist. The project owner reported that it boots as a Live CD in VirtualBox
  but has no install-to-disk option and shows the Debian boot menu.
- **Config changed, not rebuilt (stopped at the owner's request):** Calamares
  installer + GRUB packages added, `--debian-installer none`, and BIOS/UEFI boot
  menus patched to start the Live system immediately (owner's preference: boot
  straight into Live; install locally from the desktop is optional). The ISO in
  `dist/` predates these changes. Next build must be run and validated before
  anything is claimed about them. `images/astroberry-test/README.md` has the details.
- Findings from the build: `astroberry-os` hard-depends on `kstars-bleeding`
  (so its dependency list is installed instead — a candidate first upstream
  request: make KStars a Recommends); FireCapture/AstroDMx/CCDciel are in the
  `restricted` component and were left out; live-build's firmware list conflicts
  with Astroberry's INDI drivers via `indi-dsi`; installing Astroberry did not
  pull in `brltty`; live-build's `--debian-installer live` yields no installer
  (only "Live system" boot entries), so Calamares is used instead; the build
  script originally wrote the container's `/workspace/...` path into the `.sha256`
  file (fixed).
- Build tips: run the Docker build with `.\images\astroberry-test\build-iso.ps1`;
  when stopping a build, stop only the container from image
  `astroberry-amd64-smoke-builder:local` (`docker ps --filter ancestor=...`), not all
  containers. A failed live-build leaves `chroot/root/packages.chroot` in its work
  directory (`/var/tmp/astroberry-amd64-build`, inside the container), which shows
  the exact package list apt received.
- Not yet done: any hands-on check of a running Astroberry system. Statements
  about Astroberry's runtime behaviour in the PSD (hostname, ports, services)
  still come from its READMEs and architecture document.

## Earlier work (superseded)

The first direction produced a standalone Debian 13 amd64 smoke-test ISO build
and INDI/INDI-3rdparty/PHD2 build scripts. It duplicates Astroberry and is
retained for reference only:

- `images/amd64-test/` — Dockerfile, live-build config, build/validate scripts,
  VirtualBox checklist.
- `.github/workflows/amd64-virtualbox-smoke-iso.yml` — CI build.
- `scripts/build/`, `scripts/build-galileo/` — component build scripts.

No ISO build or validation was ever confirmed successful. History: container
build failed on CRLF line endings (fixed to LF), then on `sh` vs `bash`
(entrypoint changed to `/bin/bash`); the last run was interrupted before it
returned. The Windows wrapper and CI both run a privileged Docker container
(needed by live-build); CI runner support was never confirmed.

## Next steps

0. Rebuild the ISO with the pending config (Calamares, menu bypass), confirm
   `validate-iso.sh` passes, and boot it. If the menu bypass or Calamares
   misbehaves, adjust `images/astroberry-test/` and record what was learned.
1. Boot the new ISO in VirtualBox (checklist in `images/astroberry-test/README.md`),
   and install the current Astroberry OS release on a Raspberry Pi 5, and record what it
   provides against PSD §5.1: hostname, ports,
   service names, remote desktop, hotspot, `brltty`, APT repository setup,
   Manager's extension points.
2. Contact the Astroberry maintainers; the two repositories under
   `gordtulloch/` are forks of `astroberry-official/*`. Agree contribution flow
   and which Galileo pieces go upstream first.
3. Spike: run Galileo and WebConnect by hand on stock Astroberry (own
   virtual environment, systemd units, ports), alongside Manager and INDI Web
   Manager.
4. Settle the PSD §11 decisions: name, hostname, repository hosting, Python
   environment, web arrangement, pre-integrated image, fate of the superseded
   ISO work.
5. Then begin Debian packaging (`galileo`, `galileo-webconnect`,
   `galileo-astroberry`) following Astroberry's build conventions.

## Housekeeping to consider

- Galileo's own repository and wiki: the wiki's *Installing INDI* article
  already mentions Astroberry as a ready-made option and remains accurate. When
  packages exist, add install instructions there and to the Galileo README and
  CHANGELOG as that repository's rules require.
- The WebConnect and MobileConnect plugin documents in the Galileo repository
  have uncommitted changes in progress; coordinate any cross-references
  (WebConnect on Astroberry) with them rather than editing them from here.
