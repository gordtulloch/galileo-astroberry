# Galileo Linux Handoff Progress

## Current task

Prepare an initial **amd64 Debian ISO for a VirtualBox boot/install smoke test**.
The user selected `boot_install` scope: validate the base OS boot/install,
networking, SSH, and package manifest only. This is not yet a Galileo Linux
product image.

## Project decisions captured so far

- Debian-based Galileo imaging distribution for Raspberry Pi 4 and newer
  (64-bit ARM) and 64-bit amd64.
- amd64 deliverable: bootable ISO; Raspberry Pi deliverable: disk image written
  to microSD through Raspberry Pi Imager.
- Headless by default; Flask web interface is intended as the primary user
  interface and SSH is available for administration/recovery.
- First boot provides a wireless setup SSID; UI configures local Wi-Fi; device
  falls back to hotspot if no configured network is available.
- Default hostname/network name is `galileo.local`, changeable in the web UI.
- Include INDI and INDI-3rdparty. Stable is default; user may select nightly.
  Selection does not trigger an update; the next manually run update uses that
  channel. No scheduled nightly updates are required.
- Project source updates are user initiated and retrieve source through Git,
  then build applicable components. Normal Debian OS packages are managed
  through APT.
- `brltty` must not be installed/enabled because it can interfere with USB
  serial astronomy devices.
- Current ISO test is Debian 13 (Trixie), amd64, in VirtualBox. Product
  application, web UI, Galileo, INDI, and Raspberry Pi support are intentionally
  excluded from this first smoke image.

## Files created/changed for the smoke build

- `images/amd64-test/Dockerfile` — Debian Trixie container with live-build and
  ISO build dependencies.
- `images/amd64-test/build-iso.ps1` — Windows PowerShell Docker wrapper.
- `images/amd64-test/build-iso.sh` — invokes live-build, validates output, and
  copies ISO/checksum to `dist/`.
- `images/amd64-test/validate-iso.sh` — checks El Torito boot catalog, ISO
  package manifest, required packages, and that `brltty` is absent.
- `images/amd64-test/config/package-lists/galileo-test.list.chroot` — smoke
  image packages (live installer, network tools, SSH, NetworkManager, Avahi).
- `images/amd64-test/config/hooks/normal/0990-check-smoke-image.chroot` —
  fails build if `brltty` appears or required packages are missing; enables
  SSH, NetworkManager, and Avahi.
- `images/amd64-test/README.md` — Docker build instructions and manual
  VirtualBox validation checklist.
- `.github/workflows/amd64-virtualbox-smoke-iso.yml` — manually runnable and
  path-triggered CI build, publishes ISO and checksum.
- `README.md` — updated project status to describe the initial ISO workflow.

## Build environment and attempts

- Workspace: `C:\Projects\GalileoLinux`.
- Windows host. Docker Desktop is installed and running; `docker ps` succeeded
  after initial Docker daemon API failure.
- No WSL Linux distribution was available.
- Docker builder image `galileo-linux-amd64-smoke-builder:local` built
  successfully from `images/amd64-test/Dockerfile`.
- First container build attempt failed because the mounted shell scripts had
  Windows CRLF line endings; this was corrected to LF.
- A retry then failed with `set: pipefail` because `/bin/sh` was invoked even
  though the script uses Bash strict mode. The Docker entrypoint was changed to
  `/bin/bash`, and Bash availability was verified in the image.
- The latest `docker run --rm --privileged ...` ISO build was started but
  execution was interrupted before the command returned. No ISO build or
  validation success has been confirmed. PowerShell reports no remaining
  sessions, so check whether `dist/` or generated build state exists before
  deciding whether to rerun.
- Do not tell the user that an ISO has been completed until a successful build
  and validation are confirmed.

## Next steps

1. Inspect `C:\Projects\GalileoLinux\dist` and
   `C:\Projects\GalileoLinux\images\amd64-test` for partial build output.
2. Rerun the container build using Docker Desktop:

   ```powershell
   docker build --platform linux/amd64 --tag galileo-linux-amd64-smoke-builder:local --file 'C:\Projects\GalileoLinux\images\amd64-test\Dockerfile' 'C:\Projects\GalileoLinux'
   docker run --rm --privileged --platform linux/amd64 --volume 'C:\Projects\GalileoLinux:/workspace' --workdir /workspace galileo-linux-amd64-smoke-builder:local
   ```

   Capture build output to a log if needed. The build downloads Debian packages,
   so allow a long run and adequate free disk space.
3. If build fails, diagnose/fix the first actual `live-build` failure. Likely
   areas to check include whether the selected `live-build` version accepts
   `--debian-installer live`, hook directory/stage semantics, package manifest
   location inside the produced ISO, and availability of installer packages
   for Trixie.
4. Confirm the final ISO and `.sha256` under `dist/`, run the ISO validation,
   verify `brltty` absent from the package manifest, and inspect boot catalog.
5. If feasible, boot the ISO in VirtualBox and complete the live boot and
   installation smoke checklist. The current environment does not establish
   that VirtualBox is installed or available.
6. Update the user with the exact artifact path, validation results, and any
   remaining VirtualBox/manual checks.

## Known review concerns

- The test-image README describes a live account and SSH. Confirm the default
  live account authentication and ensure the test image is explicitly limited
  to isolated development use; avoid implying production-safe access controls.
- The Windows Docker wrapper invokes a privileged container. This is expected
  for `live-build` chroot/mount operations, but document that Docker Desktop
  must be trusted and running.
- `.github/workflows/amd64-virtualbox-smoke-iso.yml` currently runs a
  privileged Docker container in CI. Confirm GitHub-hosted runner support.
- Workspace root was reported as not a Git repository; do not assume git
  status/diff is available.
