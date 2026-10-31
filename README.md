# Galileo on Astroberry

This project turns an [Astroberry OS](https://github.com/gordtulloch/astroberry-os)
system into a dedicated [Galileo](https://github.com/gordtulloch/Galileo)
astrophotography controller. Astroberry OS is a GPL-3.0 operating system for
controlling astronomy equipment on Raspberry Pi 4/5 and amd64 computers. It
already provides the base system, INDI and INDI-3rdparty drivers, PHD2, plate
solvers, a wireless hotspot, a remote desktop in the browser and over VNC,
and a web interface
([Astroberry Manager](https://github.com/gordtulloch/astroberry-manager)).

We do **not** build a separate operating system. Galileo is layered on top of
Astroberry OS as additional packages, using the
[WebConnect](https://github.com/gordtulloch/Galileo-Plugins/tree/main/webconnect) plugin for
browser access, and leaving Astroberry's own code untouched. The aim is to
contribute every Galileo function back to Astroberry so that all Astroberry
users can use it. Both projects are GPL-3.0.

> This repository was renamed from GalileoLinux to `galileo-astroberry` because it
> no longer describes an operating system. The old URL redirects.

## Project status

**Scope stage.** The scope was rewritten around Astroberry OS. Galileo will be
developed and tested on the **official Astroberry OS amd64 distribution image**,
used unmodified; this project does not build or regenerate an operating system
image. An earlier attempt to rebuild an Astroberry-like ISO from Astroberry's APT
repository has been retired and its code deleted (it remains in git history).
No Galileo package, repository, or service integration exists.

Earlier work from the from-scratch direction (OS image builds, CI, and
INDI/PHD2 build scripts) duplicated Astroberry and has been deleted; it remains
in git history (PSD, section 12).

## What the Galileo layer adds

| | Provided by |
|---|---|
| Operating system images (Pi arm64, amd64), Wi-Fi hotspot, remote desktop, file sharing | Astroberry OS |
| INDI, INDI-3rdparty drivers, PHD2, StellarSolver, KStars, ASTAP/Astrometry.net | Astroberry OS |
| System web pages, INDI Web Manager, APT repository (stable/testing/staging) | Astroberry OS / Astroberry Manager |
| Galileo application as a Debian package, with its own isolated Python environment | **This project** |
| WebConnect (browser operation of Galileo) as a Debian package | **This project** |
| systemd units, drop-ins, desktop launcher, and settings that integrate Galileo with Astroberry's INDI, PHD2, and solvers | **This project** |
| Link between Astroberry Manager and WebConnect | **This project**, upstreamed where possible |
| Galileo APT repository, later merged into Astroberry's | **This project** |
| Upstream pull requests to Astroberry | **This project** |

Updates arrive through APT, the same as every other Astroberry package. There
is no separate project update function.

## Intended installation (planned, not available)

Install Astroberry OS from [astroberry.io](https://astroberry.io/download) or
onto an existing Debian Trixie / Raspberry Pi OS system as Astroberry
documents, add the Galileo repository, and install the meta-package:

```
sudo apt install galileo-astroberry
```

The repository, package names, and this command are proposals; none exist yet.

## Project scope

See the [Project Scope Document](docs/PSD.md) for principles, requirements,
architecture, milestones, and open decisions. [CLAUDE.md](CLAUDE.md) and
[Progress.md](Progress.md) are working notes for contributors.

## Review questions

1. The layering rules: Astroberry stays unmodified; Galileo is additional
   packages only.
2. Default hostname (PSD, section 11).
3. Separate Galileo APT repository versus contributing packages to
   Astroberry's from the start.
4. Whether Galileo package builds should reuse the Docker-builder approach of
   the deleted image builds (available in git history).
