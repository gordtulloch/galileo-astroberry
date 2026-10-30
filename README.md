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
[WebConnect](https://github.com/gordtulloch/Galileo-WebConnect) plugin for
browser access, and leaving Astroberry's own code untouched. The aim is to
contribute every Galileo function back to Astroberry so that all Astroberry
users can use it. Both projects are GPL-3.0.

> The repository is still called GalileoLinux. The name is under review
> because it no longer describes an operating system (see the PSD, section 11).

## Project status

**Scope stage, plus one base image.** The scope was rewritten around Astroberry
OS. A Debian 13 (Trixie) amd64 ISO with Astroberry OS installed from its own
APT repository, without KStars, builds and passes its automated checks and
starts as a Live CD ([`images/astroberry-test/`](images/astroberry-test/)). That
first build has no installer and shows the boot menu; the configuration has since
been changed to boot straight into the Live system and to include a desktop
installer, but **has not been rebuilt**. No Galileo package, repository, or service
integration exists.

The repository also contains work from the earlier from-scratch direction: a
smoke-test ISO build that compiles INDI and PHD2 itself
([`images/amd64-test/`](images/amd64-test/)),
its CI workflow, and INDI/INDI-3rdparty/PHD2 build scripts
([`scripts/build/`](scripts/build/)). It duplicates what Astroberry provides,
was never confirmed to build successfully, and is **superseded**. It is kept
for reference until its fate is decided (PSD, section 12).

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
2. Repository name and default hostname (PSD, section 11).
3. Separate Galileo APT repository versus contributing packages to
   Astroberry's from the start.
4. Whether to retire the superseded ISO build or reuse its Docker-builder and
   validation approach for Galileo package builds.
