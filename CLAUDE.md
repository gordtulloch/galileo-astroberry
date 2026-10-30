# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

Galileo Linux is a *planned* Debian-based OS (Raspberry Pi 4+ arm64 and amd64) for running the Galileo imaging system and INDI headlessly, with a Flask web UI as the primary interface. Only the scope ([docs/PSD.md](docs/PSD.md), [README.md](README.md)) and an **amd64 VirtualBox smoke-test ISO build** exist. The Flask UI, Galileo/INDI integration, update function, and Raspberry Pi image are not implemented — don't describe them as existing. [Progress.md](Progress.md) is a handoff log with build history and open next steps; check it first. Update the README/PSD status if that changes.

Not a git repository (no git status/diff available). Windows host; builds run in Docker Desktop.

## Build commands

The smoke ISO (Debian 13 Trixie, amd64, `live-build`) lives in [images/amd64-test/](images/amd64-test/):

```powershell
.\images\amd64-test\build-iso.ps1      # from repo root: builds the builder image, runs live-build in a --privileged container
```

Equivalent manual steps (also what CI runs):

```powershell
docker build --platform linux/amd64 --tag galileo-linux-amd64-smoke-builder:local --file images\amd64-test\Dockerfile .
docker run --rm --privileged --platform linux/amd64 --volume "${PWD}:/workspace" --workdir /workspace galileo-linux-amd64-smoke-builder:local
```

Output: `dist/galileo-linux-amd64-smoke-<YYYYMMDD>.iso` plus `.sha256`. Needs ~20 GB free disk and a long run. No unit tests or linter exist; "testing" is `validate-iso.sh` (run automatically by the build) plus the manual VirtualBox checklist in [images/amd64-test/README.md](images/amd64-test/README.md).

No ISO build has been confirmed successful yet (see Progress.md) — don't claim one is complete without a validated run.

## Architecture of the image build

- [Dockerfile](images/amd64-test/Dockerfile) provides the builder container; its entrypoint runs [build-iso.sh](images/amd64-test/build-iso.sh) via `/bin/bash` (scripts use bash strict mode, not POSIX sh).
- `build-iso.sh` must run as root: `lb clean` → `lb config` (trixie, amd64, iso-hybrid, `--debian-installer live`, `main contrib non-free-firmware`, no apt recommends) → `lb build` → `validate-iso.sh` → copy ISO + sha256 to `dist/`. It operates in-place in `images/amd64-test/`, so `lb` state (`chroot/`, `cache/`, `binary/`, etc.) accumulates there; `config/` and `local/` hold the real source configuration.
- Package selection: `config/package-lists/galileo-test.list.chroot`. Build-time chroot hook `config/hooks/normal/0990-check-smoke-image.chroot` enables ssh/NetworkManager/Avahi and fails the build if `brltty` is present or required packages are missing. `validate-iso.sh` independently checks the ISO's El Torito boot catalog and package manifest.
- CI: [.github/workflows/amd64-virtualbox-smoke-iso.yml](.github/workflows/amd64-virtualbox-smoke-iso.yml) runs the same Docker build (manual dispatch, or PRs touching the workflow/`images/amd64-test/**`) and uploads the ISO as an artifact.

## Gotchas and constraints

- **Shell scripts must keep LF line endings.** CRLF (from Windows editing) already broke a container build once.
- **`brltty` must never be installed or enabled** — it interferes with USB-serial astronomy devices. Keep both the hook check and `validate-iso.sh` enforcing this.
- The smoke ISO uses live-build's default live account (here `username=galileo`) and runs SSH; it is for isolated development testing only, never the product image.
- Do not edit or search inside `images/amd64-test/chroot/` — it is generated build output (thousands of files).
- Product decisions to preserve (from the PSD): default hostname `galileo.local` (changeable in UI); first-boot setup Wi-Fi SSID with fallback hotspot; INDI/INDI-3rdparty stable by default with a user-selectable nightly channel that only applies on the next *manual* update (no scheduled updates); updates fetch project source via Git and build it, while OS packages go through APT; Raspberry Pi deliverable is a raw disk image for Raspberry Pi Imager, not an ISO.
