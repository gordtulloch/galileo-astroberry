# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

The project is **Galileo layered on Astroberry OS**, not a standalone operating system. Galileo is added to a stock [Astroberry OS](https://github.com/gordtulloch/astroberry-os) system (with [Astroberry Manager](https://github.com/gordtulloch/astroberry-manager) as its web interface) as extra Debian packages, using the WebConnect plugin ([Galileo-WebConnect](https://github.com/gordtulloch/Galileo-WebConnect)) for browser access. The aim is to contribute all Galileo functions back to Astroberry. Both are GPL-3.0. Authoritative scope: [docs/PSD.md](docs/PSD.md); overview: [README.md](README.md); working log: [Progress.md](Progress.md) — check it first.

**Base system: the official Astroberry OS amd64 distribution image.** Galileo is developed and tested on the image Astroberry publishes, unmodified. We do not regenerate or rebuild the operating system image. The earlier attempt to assemble a look-alike from Astroberry's APT repository (`images/astroberry-test/`, `live-build` in Docker) is **retired and its code deleted** (recoverable from git history, commit 8b706b2 and earlier): it never matched the official image (no first-boot setup, installer, or branding) and cannot be upstreamed. Don't recreate it, and don't claim any ISO from it was validated. No Galileo package, APT repository, or service integration exists. Don't describe them as existing.

The official image has not yet been inspected hands-on. Boot it (VirtualBox) and record its hostname, ports, accounts, services, and `brltty` status before relying on any runtime fact.

This is a git repository (remote history exists). Windows host; any Linux build runs in Docker Desktop.

## Rules of the layer (from the PSD)

- **Leave Astroberry untouched.** Never fork, patch, divert, or overwrite Astroberry-owned files. Integrate with additional packages, systemd drop-ins, separate config files, and extra units. If Astroberry lacks an extension point, the answer is an upstream contribution, not a local patch. The `gordtulloch/astroberry-os` and `gordtulloch/astroberry-manager` forks exist for exactly this: if tight Galileo integration needs a change to Astroberry, make it as a PR from the fork to the upstream project, never as a patch applied on top of the image.
- **Don't duplicate Astroberry.** Hotspot, Wi-Fi onboarding, remote desktop, INDI/INDI-3rdparty/PHD2/solver builds, OS images, and OS updates are Astroberry's. PSD §5.1 lists them as *inherited* — verify, don't build.
- **Design every piece to be upstreamable**: generic, optional, GPL-3.0, following Astroberry's packaging conventions (Docker-builder + GitHub Actions, `reprepro` repository with `trixie`/`trixie-testing`/`trixie-staging`). Keep a list of integration points and their upstream status (PSD UP-01).
- **Use WebConnect** for browser operation of Galileo. Don't write a new general web UI here. Functions WebConnect excludes (profiles, Observatories, safety limits, Options) are reached through the Galileo desktop app in Astroberry's remote desktop.
- **Updates are APT packages.** No Git-based on-device update function, no stable/nightly INDI channel logic of our own.
- **Keep Python environments isolated.** Astroberry Manager pins its own requirements (Flask, gevent, `pyindi-client`, …); Galileo needs its own environment and uses its own pure-Python INDI client.
- Facts about Astroberry in these docs come from its READMEs and `docs/ARCHITECTURE.md`; verify against a running Astroberry system before relying on anything not stated there (default hostname, ports, hook points, whether `brltty` is shipped).

## Removed earlier work

Earlier directions built operating system images (a from-scratch Debian ISO, then a rebuilt Astroberry image) and INDI/PHD2 build scripts. All of it, its CI workflow, and the built ISOs were **deleted**; it remains only in git history. It duplicated Astroberry and never produced a validated image. Don't recreate it without a decision recorded in PSD §11/§12. `scripts/build-galileo/` was kept because it may inform Galileo packaging.

Gotchas for any shell script or container work here:

- **Shell scripts must keep LF line endings.** CRLF from Windows editing already broke a container build once.
- Scripts use bash strict mode; invoke with `/bin/bash`, not `sh`.
- **`brltty` must never be installed or enabled** (breaks USB-serial astronomy devices). Verify it on Astroberry rather than assuming.
