# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

The project is **Galileo layered on Astroberry OS**, not a standalone operating system. Galileo is added to a stock [Astroberry OS](https://github.com/gordtulloch/astroberry-os) system (with [Astroberry Manager](https://github.com/gordtulloch/astroberry-manager) as its web interface) as extra Debian packages, using the WebConnect plugin ([Galileo-WebConnect](https://github.com/gordtulloch/Galileo-WebConnect)) for browser access. The aim is to contribute all Galileo functions back to Astroberry. Both are GPL-3.0. Authoritative scope: [docs/PSD.md](docs/PSD.md); overview: [README.md](README.md); working log: [Progress.md](Progress.md) — check it first.

Only the base image exists: [images/astroberry-test/](images/astroberry-test/) builds a Debian 13 Trixie amd64 ISO with Astroberry OS installed from Astroberry's APT repository, without KStars (build with `.\images\astroberry-test\build-iso.ps1`; output in `dist/`). The ISO in `dist/` (first build) boots as a Live CD per the owner but has no installer and shows a boot menu; the config has since been changed (Calamares, boot-menu bypass) and **not rebuilt** — don't claim the new behaviour works until it is built and validated. Read `images/astroberry-test/README.md` Status first. No Galileo package, APT repository, or service integration exists. Don't describe them as existing.

Install Astroberry by listing the packages `astroberry-os` depends on (minus `kstars-bleeding`), not the meta-package. In live-build keep `--firmware-chroot false` (its firmware list pulls in `indi-dsi`, which conflicts with Astroberry's `indi-3rdparty-drivers`) and register the repository via `config/archives/` (files copied into the chroot later are missed by live-build's `apt update`). Update README/PSD status if that changes.

This is a git repository (remote history exists). Windows host; any Linux build runs in Docker Desktop.

## Rules of the layer (from the PSD)

- **Leave Astroberry untouched.** Never fork, patch, divert, or overwrite Astroberry-owned files. Integrate with additional packages, systemd drop-ins, separate config files, and extra units. If Astroberry lacks an extension point, the answer is an upstream contribution, not a local patch.
- **Don't duplicate Astroberry.** Hotspot, Wi-Fi onboarding, remote desktop, INDI/INDI-3rdparty/PHD2/solver builds, OS images, and OS updates are Astroberry's. PSD §5.1 lists them as *inherited* — verify, don't build.
- **Design every piece to be upstreamable**: generic, optional, GPL-3.0, following Astroberry's packaging conventions (Docker-builder + GitHub Actions, `reprepro` repository with `trixie`/`trixie-testing`/`trixie-staging`). Keep a list of integration points and their upstream status (PSD UP-01).
- **Use WebConnect** for browser operation of Galileo. Don't write a new general web UI here. Functions WebConnect excludes (profiles, Observatories, safety limits, Options) are reached through the Galileo desktop app in Astroberry's remote desktop.
- **Updates are APT packages.** No Git-based on-device update function, no stable/nightly INDI channel logic of our own.
- **Keep Python environments isolated.** Astroberry Manager pins its own requirements (Flask, gevent, `pyindi-client`, …); Galileo needs its own environment and uses its own pure-Python INDI client.
- Facts about Astroberry in these docs come from its READMEs and `docs/ARCHITECTURE.md`; verify against a running Astroberry system before relying on anything not stated there (default hostname, ports, hook points, whether `brltty` is shipped).

## Superseded earlier work

The earlier direction built a standalone Debian OS. These parts remain but are **superseded** and not part of the product; do not extend them without a decision recorded in PSD §11/§12:

- `images/amd64-test/` — a Debian 13 (Trixie) amd64 smoke-test ISO (`live-build` in a privileged Docker container).
- `.github/workflows/amd64-virtualbox-smoke-iso.yml` — its CI build.
- `scripts/build/` — INDI/INDI-3rdparty/PHD2 build scripts (duplicate Astroberry's workflows). `scripts/build-galileo/` may inform Galileo packaging.

No ISO build was ever confirmed successful — don't claim one is. If you do work on them:

```powershell
.\images\amd64-test\build-iso.ps1      # from repo root; output dist/galileo-linux-amd64-smoke-<YYYYMMDD>.iso + .sha256
```

Gotchas that still apply to any shell script or container work here:

- **Shell scripts must keep LF line endings.** CRLF from Windows editing already broke a container build once.
- Scripts use bash strict mode; invoke with `/bin/bash`, not `sh`.
- Don't edit or search `images/amd64-test/chroot/` — generated build output.
- **`brltty` must never be installed or enabled** (breaks USB-serial astronomy devices). Verify it on Astroberry rather than assuming.
- The smoke ISO's default live account and SSH are for isolated testing only.
