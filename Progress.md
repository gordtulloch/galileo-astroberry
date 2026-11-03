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
- **Decision: use the official Astroberry OS amd64 distribution image, unmodified,
  and stop regenerating it.** The owner is downloading it to run beside our
  rebuild; our rebuild was terminated before completion. The rebuild from
  Astroberry's APT repository (`images/astroberry-test/`)
  is retired and its code deleted (in git history). Why: it needed hand-built installer, branding and first-boot behaviour
  that the official image already has, and results on it would not prove Galileo
  works on what Astroberry users run.
- What the retired attempt established (kept for reference): `astroberry-os`
  hard-depends on `kstars-bleeding` (a candidate upstream request: make it a
  Recommends); FireCapture/AstroDMx/CCDciel are in the `restricted` component;
  installing Astroberry from the repository did not pull in `brltty`;
  live-build's firmware list conflicts with Astroberry's INDI drivers via
  `indi-dsi`. Its first ISO (`debian-trixie-astroberry-amd64-smoke-20261031.iso`,
  in `dist/`, git-ignored build output) passed its automated package checks and
  booted as a Live CD per the owner, but had no installer and showed the boot menu.
  Uncommitted Calamares launcher/branding hooks written for it were never built or
  tested and were discarded with it. Nothing from it is validated.
- Not yet done: any hands-on check of a running Astroberry system. Statements
  about Astroberry's runtime behaviour in the PSD (hostname, ports, services)
  still come from its READMEs and architecture document.

## Earlier work (deleted)

Two earlier directions built OS images: a standalone Debian 13 amd64 ISO
(`images/amd64-test/`, with a CI workflow and `scripts/build/` INDI/PHD2 build
scripts), then an Astroberry look-alike (above). All code and built ISOs were
deleted at the owner's request; they remain in git history. No ISO from either was
ever validated. Only `scripts/build-galileo/` remains, as input for Galileo packaging.

## Next steps

0. Boot the official Astroberry OS amd64 image in VirtualBox (and install it to a
   virtual disk), then install the current release on a Raspberry Pi 5, and record
   what it provides against PSD §5.1: hostname, ports, service names, remote
   desktop, hotspot, `brltty`, APT repository setup, Manager's extension points.
   Compare with the PSD's README-derived claims and correct them.
2. Where tight integration needs a change in Astroberry, the owner's forks
   (`gordtulloch/astroberry-os`, `gordtulloch/astroberry-manager`) are the route for
   upstream PRs; list each such change in the PSD UP-01 integration list.
   Contact the Astroberry maintainers; the two repositories under
   `gordtulloch/` are forks of `astroberry-official/*`. Agree contribution flow
   and which Galileo pieces go upstream first.
3. Spike: run Galileo and WebConnect by hand on stock Astroberry (own
   virtual environment, systemd units, ports), alongside Manager and INDI Web
   Manager.
4. Settle the PSD §11 decisions: name, hostname, repository hosting, Python
   environment, web arrangement, pre-integrated image, reuse of the Docker-builder
   approach for package builds (the image builds were deleted).
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

## Engine service unit (HEAD-150) — 2026-11-03

`packaging/systemd/galileo-engine.service` runs `galileo --engine` as a systemd service: `Type=notify` (the engine
sends `READY=1`), ordered after the INDI units, `Restart=on-failure` with a growing delay, at most 5 starts in 10
minutes, no restart on exit code 3 (another engine holds the lock), journal logging.

Not verified and not packaged: the unit has not been run on an Astroberry image; `User=astroberry` and the INDI unit
names in `After=` are assumptions to check on the booted image; enabling/disabling it with the Galileo package needs the
package, which does not exist yet.
