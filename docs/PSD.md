# Galileo on Astroberry — Project Scope Document

> **Revision note.** The original scope of this project was a from-scratch
> Debian-based operating system ("Galileo Linux") with its own image build,
> Flask web interface, Wi-Fi onboarding, remote desktop, and INDI/PHD2 build
> system. That direction is **superseded**. The operating system is now
> [Astroberry OS](https://github.com/gordtulloch/astroberry-os), and Galileo is
> layered on top of it. Section 12 records what changed and what happens to
> the earlier work.

## 1. Purpose

Provide a dedicated, headless astrophotography controller that runs the
[Galileo](https://github.com/gordtulloch/Galileo) imaging system on
**Astroberry OS**, on Raspberry Pi 4/5-class ARM computers and 64-bit amd64
computers.

Astroberry OS is an existing GPL-3.0 Debian/Raspberry Pi OS-based distribution
for controlling astronomy equipment. It already supplies the operating system
image, INDI and INDI-3rdparty, PHD2, StellarSolver, KStars, a wireless hotspot,
remote desktop through a web interface and VNC clients, file sharing, an APT
repository with stable/testing/staging channels, and a web interface
([Astroberry Manager](https://github.com/gordtulloch/astroberry-manager)).
This project does not rebuild any of that. It adds the Galileo-specific
functions on top and, wherever a function is generally useful, contributes it
back to Astroberry.

This document records scope and decisions to be validated. It is a project
definition, not a claim that any of it exists yet.

## 2. Guiding principles

1. **Leave Astroberry untouched.** Galileo is delivered as additional
   packages and configuration layered over a stock Astroberry OS. We do not fork
   or patch Astroberry's code to make Galileo work. Where Astroberry offers an
   extension point, use it; where it does not, the fix is an upstream
   contribution (principle 3), not a local patch.
2. **Do not duplicate.** If Astroberry already provides a capability (hotspot,
   remote desktop, INDI/PHD2 builds, OS updates, system pages), Galileo uses
   it. Requirements for such capabilities are *inherited* and only verified
   here (section 5.1).
3. **Contribute back.** The end state is that Galileo's functions are available
   to every Astroberry user. Each deliverable is designed to be upstreamable:
   generic, optional, GPL-3.0, following Astroberry's packaging and
   contribution conventions.
4. **Use WebConnect where appropriate.** Browser access to a running Galileo
   is provided by the [WebConnect](https://github.com/gordtulloch/Galileo-Plugins/tree/main/webconnect)
   plugin (a Flask application supervised by Galileo's Master node), not by a
   new web interface written for this project.
5. **Same licence.** Astroberry OS and Astroberry Manager are GPL-3.0; Galileo
   is GPL-3.0. There is no licensing obstacle to layering or to upstream
   contribution. Contributions keep GPL-3.0(-or-later where the receiving file
   already says so) and preserve upstream copyright and author notices.

## 3. Goals

1. A stock Astroberry OS install (Raspberry Pi image or amd64) becomes a
   Galileo imaging host by installing a small number of Galileo packages — no
   separate operating system image is required.
2. Galileo runs headlessly under Astroberry's service management, using
   Astroberry's INDI server and drivers, PHD2, and plate solvers.
3. A user reaches Galileo from a browser through WebConnect, alongside the
   Astroberry Manager pages they already use, with a single obvious way to move
   between the two.
4. Galileo installs, upgrades, and removes cleanly through APT, with user data
   preserved.
5. The Galileo-specific work is upstreamed to Astroberry in stages.
6. An optional, pre-integrated image (Astroberry OS plus the Galileo packages)
   may be offered for convenience, built with Astroberry's own build workflow
   rather than a separate one.

## 4. Scope

### 4.1 In scope

- **Packaging.** Debian packages for Galileo and its integration, built for
  arm64 and amd64 and installable on Astroberry OS (Debian Trixie base):
  - `galileo` — the application and its Python environment;
  - `galileo-webconnect` — the WebConnect plugin and its Flask application;
  - a Galileo meta-package (working name `galileo-astroberry`) that depends on
    the above and applies the integration configuration below. Naming follows
    Astroberry's `astroberry-os` / `astroberry-os-sysmod` pattern.
- **A Galileo APT repository** laid out like Astroberry's (`trixie` stable,
  `trixie-testing`, `trixie-staging`, signed), to be merged into Astroberry's
  repository if and when upstream agrees.
- **Service integration.** systemd units for Galileo (headless/service mode)
  and WebConnect, ordered after Astroberry's INDI services and running as an
  unprivileged service account in the device groups Astroberry already uses.
- **INDI integration.** Galileo connects to the INDI server Astroberry runs,
  using Galileo's own INDI client. Verify coexistence with Astroberry Manager
  and INDI Web Manager (two clients, shared profiles, port 7624 and 8624).
- **Guiding and solving integration.** Galileo uses Astroberry's PHD2 and the
  plate solvers Astroberry packages (StellarSolver, Astrometry.net, ASTAP).
- **Web integration.** WebConnect reachable from Astroberry Manager (link or
  tile), reverse-proxy or port arrangement with TLS, and shared sign-in where
  Astroberry provides a mechanism that allows it.
- **Remote desktop.** The Galileo desktop application runs in Astroberry's
  existing remote desktop (web and VNC) for the functions WebConnect does not
  cover (equipment profiles, Observatories, safety limits, Options, plugin
  settings).
- **Data locations.** Settings (Galileo's database), equipment profiles, and
  captured images in locations that survive Galileo and Astroberry upgrades.
- **Upstream contribution.** Pull requests, issues, and design discussion with
  the Astroberry maintainers; contribution-ready packaging.
- **Documentation and validation** on representative Pi and amd64 hardware.

### 4.2 Out of scope

- Building or maintaining a separate operating system, base image, kernel, or
  firmware.
- Re-implementing or forking: Astroberry Manager, the hotspot, remote desktop,
  file sharing, the INDI/INDI-3rdparty/PHD2/KStars build workflows, the APT
  repository tooling, or the system image build workflows.
- A second general-purpose web interface or INDI driver-management UI. Driver
  and profile management stays with Astroberry (Manager / INDI Web Manager)
  unless a specific Galileo need cannot be met there, in which case it becomes
  an upstream contribution.
- Patching Astroberry source in this project's packages.
- Raspberry Pi models earlier than Raspberry Pi 4; 32-bit systems.
  (Astroberry's supported-hardware list governs; Galileo adds no wider claim.)
- Guaranteeing every INDI driver or peripheral works.
- Internet exposure of the web interface (WebConnect is for LAN/VPN).

## 5. Requirements

### 5.1 Inherited from Astroberry OS (verify, do not build)

These were requirements of the earlier from-scratch scope. They are now
provided by Astroberry OS. This project's obligation is to confirm each still
holds with the Galileo layer installed and to record gaps for upstream.
"Verified" means a recorded check on the target hardware; none is done yet.

| ID | Capability | Provided by | Check with Galileo installed |
|---|---|---|---|
| PLAT-01 | arm64 Raspberry Pi image (Pi 4 and Pi 5) | Astroberry OS release workflow | Galileo packages install and run on arm64 |
| PLAT-02 | amd64 system (Astroberry OS 3.2+) | Astroberry OS release workflow | Galileo packages install and run on amd64; document UEFI/BIOS behaviour as Astroberry does |
| PLAT-04 | Raspberry Pi Imager-compatible disk image | Astroberry OS release | Write image, boot, install Galileo packages |
| PLAT-06 | No `brltty` | to be confirmed | Confirm absent after install; if Astroberry ships it, raise upstream |
| WEB-06/07 | Hotspot and Wi-Fi onboarding | Astroberry OS sysmod | Galileo does not interfere; WebConnect reachable over the hotspot |
| WEB-08/09 | Device name and mDNS fallback | Astroberry OS / Manager | See open decision on default name |
| DESK-01–05 | Remote desktop via web and VNC | Astroberry OS sysmod | Galileo desktop application launches in it (section 5.4) |
| INDI-01–06 | INDI, INDI-3rdparty, drivers, profiles, channels | Astroberry packages, INDI Web Manager, Manager | Galileo uses the same INDI server and profiles; stable/testing/staging repository channels apply |
| GAL-05 | OS and package updates via APT | Astroberry APT repository | Galileo packages update the same way |
| OPS-01/02 | Managed services, least privilege | Astroberry systemd units | Galileo units follow the same conventions |

### 5.2 Packaging and installation

- **PKG-01:** Provide Debian packages for Galileo and WebConnect for arm64 and
  amd64 on the Debian Trixie base used by Astroberry OS.
- **PKG-02:** A single command installs the Galileo layer on an Astroberry OS
  system (for example `sudo apt install galileo-astroberry`), after adding the
  Galileo repository with its signing key. The procedure mirrors Astroberry's
  documented repository setup, including its APT pin guidance.
- **PKG-03:** Packages must not overwrite, divert, or modify files owned by
  Astroberry packages. Integration is by drop-ins, separate configuration
  files, and additional units.
- **PKG-04:** Declare dependencies on Astroberry packages by package name and
  version range; fail clearly if a required Astroberry component is missing or
  too old.
- **PKG-05:** Removing the Galileo packages restores the system to stock
  Astroberry behaviour and keeps user data unless purge is requested.
- **PKG-06:** Do not depend on build tools or headers at runtime.
- **PKG-07:** Provide the same package set through a stable, testing, and
  staging repository promotion path matching Astroberry's.

### 5.3 Services and INDI integration

- **SVC-01:** Galileo and WebConnect run as systemd services started after the
  Astroberry INDI services, restarted on failure, and logging to the journal.
- **SVC-02:** Services run as a dedicated or existing unprivileged account with
  only the group access (serial, USB, video) needed for equipment.
- **SVC-03:** Galileo connects to Astroberry's INDI server and respects
  profiles and drivers the user starts from Astroberry Manager / INDI Web
  Manager. Starting and stopping the server from either side is reflected in
  the other.
- **SVC-04:** Galileo uses Astroberry's PHD2 as its guider (PHD2 client) and
  the Astroberry-packaged solvers, without building its own copies.
- **SVC-05:** Resolve port and name collisions with Astroberry (web ports, INDI
  ports, mDNS names) by documented defaults, not by changing Astroberry.
- **SVC-06:** Report Galileo service state and version where Astroberry
  Manager exposes service status, if an upstream extension point exists.

### 5.4 Web and desktop access

- **WEB-01:** WebConnect is the browser interface for operating Galileo. Its
  scope, security model (approved browsers, Master-node approval, LAN/VPN only)
  and features are those in WebConnect's own documents; this project does not
  restate or extend them.
- **WEB-02:** Provide a documented, working way to move between Astroberry
  Manager and WebConnect (link, tile, or proxied path).
- **WEB-03:** WebConnect is served over TLS and authenticated as its own
  design requires. If a reverse proxy in front of both applications is used, it
  must not weaken either one's authentication.
- **WEB-04:** Functions WebConnect deliberately excludes (equipment profiles,
  Observatories, safety limits, Options, plugin settings) are reached through
  the Galileo desktop application in Astroberry's remote desktop. The Galileo
  package adds a launcher/menu entry there. This remains the case until those
  functions have a browser equivalent, which is WebConnect's roadmap, not this
  project's.
- **WEB-05:** Document authentication, network exposure, and secure defaults
  for the combined system before it is recommended for use beyond a trusted
  network.

### 5.5 Data, updates, and recovery

- **DATA-01:** Galileo's database, equipment profiles, and images live outside
  package-owned directories and survive Galileo and Astroberry upgrades and
  Astroberry image re-flashes where the user keeps the data volume.
- **DATA-02:** Galileo schema migrations run at service start and are safe to
  re-run; a failed migration leaves the previous data usable.
- **DATA-03:** Galileo updates arrive through APT like any other Astroberry
  package. There is no separate project-specific update function and no
  Git-based source update on the device. Developers who want Galileo `main`
  use the staging repository channel or install from source on their own
  machine.
- **DATA-04:** Document backup, restore, and recovery for the Galileo data
  alongside Astroberry's own guidance.
- **DATA-05:** Report installed Galileo and WebConnect versions, and the
  Astroberry release they were validated against.

### 5.6 Upstream contribution

- **UP-01:** Maintain a list of every integration point where Galileo needs
  something from Astroberry (hook, API, setting, package) and its status:
  worked around locally, proposed, accepted, merged.
- **UP-02:** Prefer contributing a general mechanism to Astroberry over a
  Galileo-specific one, and keep Galileo-specific behaviour in Galileo's own
  packages.
- **UP-03:** Each upstream contribution follows Astroberry's contribution
  guidelines, builds with its workflows, and carries no Galileo-only
  dependency.
- **UP-04:** The long-term target is that `galileo` and `galileo-webconnect`
  are available from Astroberry's own repository and, if the maintainers wish,
  installable by the `astroberry-os` meta-package or as an optional add-on.
  Until then, the Galileo repository serves them.
- **UP-05:** Track Astroberry releases; revalidate the layer on each stable
  promotion and record compatibility.

## 6. Proposed architecture

```
   Astroberry OS  (unmodified, from astroberry-os / astroberry.io APT)
   ├─ Debian Trixie / Raspberry Pi OS base, hotspot, remote desktop, file sharing
   ├─ INDI + INDI-3rdparty drivers, PHD2, StellarSolver, KStars, solvers
   ├─ INDI Web Manager (8624)  ·  INDI server (7624)
   └─ Astroberry Manager (Flask web UI)
                     ▲  uses / links to
   Galileo layer  (additional packages only)
   ├─ galileo               application + Python environment
   ├─ galileo-webconnect    WebConnect plugin + Flask application
   └─ galileo-astroberry    meta-package: units, drop-ins, launcher, config
```

- Galileo talks to the INDI server and PHD2 that Astroberry runs, over their
  normal network protocols; it imports nothing from Astroberry.
- WebConnect and Astroberry Manager are sibling web applications. Linking
  between them is the integration; neither embeds the other.
- Anything in the layer that is not Galileo-specific is a candidate for
  upstreaming first.

## 7. Deliverables

1. Integration design: the Galileo/Astroberry contract (section 6), service
   and port map, and the upstream-integration-point list (UP-01).
2. Debian packages `galileo`, `galileo-webconnect`, and the meta-package, for
   arm64 and amd64, with a build workflow that follows Astroberry's
   Docker-builder / GitHub Actions pattern.
3. Galileo APT repository (staging → testing → stable).
4. Verified installation on stock Astroberry OS on Raspberry Pi and amd64,
   recorded as a validation matrix.
5. Optional pre-integrated image, built through Astroberry's workflow.
6. User and administrator documentation, including coexistence with Astroberry
   Manager, backup, and recovery.
7. Upstream pull requests and a maintained contribution log.

## 8. Constraints, assumptions, and risks

- **Dependence on Astroberry's evolution.** Galileo follows Astroberry's
  releases, package names, and conventions. Mitigation: version-range
  dependencies, revalidation on each release (UP-05), staying close to
  unmodified Astroberry.
- **Upstream acceptance is not guaranteed.** Astroberry's maintainers decide
  what they merge. Mitigation: the layer works without acceptance; contribution
  is incremental and each piece is small and generic.
- **Maintainer relationship.** The `gordtulloch/astroberry-os` and
  `astroberry-manager` repositories are forks of
  `astroberry-official/*`. Agree contribution flow with the upstream
  maintainers before substantial work.
- **Python environment collision.** Astroberry Manager pins its own Python
  requirements (including `pyindi-client`, Flask, gevent). Galileo's
  environment must be isolated (own virtual environment under its own path) so
  neither application's dependencies break the other. Galileo uses its own
  pure-Python INDI client and does not need `pyindi-client`.
- **Two INDI clients / two web apps.** Concurrent control from Manager, INDI
  Web Manager, KStars, and Galileo can conflict (profiles started or stopped
  under a running session). Document which actions are safe while a Galileo
  session runs; consider a Galileo-side warning.
- **Port, name, and TLS collisions.** To be settled in design (SVC-05).
- **Packaging effort for Galileo.** Galileo is currently distributed as
  AppImages and bootstrap install scripts; a Debian package with a managed
  Python environment is new work and affects Galileo's own release process.
- **Hardware variability** (USB bandwidth, power, storage) is inherited from
  Astroberry and documented by it; add Galileo-specific findings only.
- **Data volume.** Captured images can be large; storage location and capacity
  reporting need a decision (DATA-01).
- **Remote administration exposure.** An imaging controller operates physical
  equipment. Inherit Astroberry's security posture, then document the
  combined system (WEB-05).

## 9. Milestones

### M1 — Contract and feasibility
- Install the current Astroberry OS release on a Pi 5 and on amd64; record
  what it already provides against section 5.1.
- Contact Astroberry maintainers; agree contribution flow and extension points.
- Spike: Galileo and WebConnect running on a stock Astroberry system by hand
  (virtual environment, units, ports), coexisting with Manager and INDI Web
  Manager.
- Decide the open items in section 11.

### M2 — Packaging
- `galileo`, `galileo-webconnect`, and meta-package build for arm64 and amd64.
- Galileo APT repository with staging/testing/stable.
- Install, upgrade, remove, and purge tested on stock Astroberry.

### M3 — Integration
- Service ordering, INDI/PHD2/solver use, Manager ↔ WebConnect navigation,
  desktop launcher, data locations.
- Coexistence tests with Manager, INDI Web Manager, and KStars.
- Validation matrix on representative hardware, with simulators where
  hardware is unavailable.

### M4 — Upstream and release
- First upstream pull requests merged or in review; contribution log current.
- Optional pre-integrated image built through Astroberry's workflow.
- Documentation, backup/recovery guidance, release notes.

## 10. Acceptance criteria

1. On a stock Astroberry OS install on Raspberry Pi (arm64) and on amd64, adding
   the Galileo repository and installing the meta-package yields a working
   Galileo and WebConnect with no manual file editing.
2. No file owned by an Astroberry package is modified by the Galileo packages;
   removing the Galileo packages returns stock behaviour.
3. Galileo uses Astroberry's INDI server, drivers, PHD2, and solvers, and can
   run a basic imaging session against INDI simulators.
4. A user can reach WebConnect from Astroberry Manager and the reverse, and
   operate Galileo from a browser without an attached display.
5. The functions WebConnect excludes are reachable through the Galileo desktop
   application in Astroberry's remote desktop.
6. Galileo data survives package upgrade and Astroberry upgrade; a documented
   recovery succeeds in validation.
7. Updates are delivered through APT; installed versions are visible.
8. The upstream-integration-point list is current, and at least the agreed
   first contribution has been submitted upstream.
9. Each release records the Astroberry release it was validated against, test
   results, checksums, and installation, security, and recovery documentation.

## 11. Decisions requiring review

- **Name.** Decided: the repository is `galileo-astroberry` (renamed from
  GalileoLinux). Whether the product keeps any "Galileo Linux" branding is open;
  "Linux" no longer describes an operating system.
- **Hostname.** Whether the layer changes the device name to `galileo.local` or
  keeps Astroberry's default. Changing it contradicts "leave Astroberry
  untouched" unless done through Astroberry's own setting; the earlier scope
  assumed `galileo.local`.
- **Repository hosting.** A separate Galileo APT repository, or contribute
  packages directly to Astroberry's from the start.
- **Python environment.** Bundled virtual environment inside the package
  versus system packages; effect on the ARM build and package size.
- **Web arrangement.** Separate ports versus a reverse proxy in front of
  Manager and WebConnect; shared sign-in feasibility (Manager uses PAM login).
- **Galileo desktop availability** over the remote desktop, and how the
  Galileo unit handles running with and without a desktop session.
- **Pre-integrated image.** Whether it is offered, and whether it is built by
  Astroberry's workflow in their repository or ours.
- **Which Galileo functions upstream first** and in what order.
- **Which Astroberry release line** is the validation baseline (current stable
  `trixie`).
- **Reuse of the deleted image-build approach** for package builds (section 12).

## 12. What changed from the earlier scope

| Earlier requirement area | Now |
|---|---|
| Own Debian-based OS, ISO and Pi image builds (PLAT) | Astroberry OS images; this project builds none. The official amd64 image is the test base, used unmodified |
| Flask web UI as the primary interface (WEB) | Astroberry Manager for system tasks; WebConnect for Galileo |
| First-boot Wi-Fi onboarding, hotspot, hostname | Inherited from Astroberry |
| INDI/INDI-3rdparty/PHD2 build scripts, stable/nightly channel (INDI, DESK-06) | Inherited: Astroberry packages and repository channels |
| VNC/noVNC remote desktop, own security model (DESK) | Inherited from Astroberry's remote desktop |
| Project update function: Git retrieval and source builds (GAL-03/04) | Removed — updates are APT packages (DATA-03) |
| Galileo source mode on the device (GAL-02) | Removed from the device; developers use staging channel or own install |
| Galileo installation (GAL-01) | Kept, now as Debian packages (PKG) |
| User data preservation, services, security (GAL-06/07, OPS) | Kept where Galileo-specific (DATA, SVC); rest inherited |
| — | New: layering rules, upstream contribution (UP) |

**Earlier work, deleted.** The earlier image builds (a from-scratch Debian ISO and a
rebuilt Astroberry image), the CI workflow, and the INDI/INDI-3rdparty/PHD2 build
scripts were built for the earlier scope, duplicate what Astroberry provides, and
have been removed; they remain in git history. The official Astroberry OS amd64
image is used instead. `scripts/build-galileo/` is kept and may inform the Galileo
packaging work. Whether to reuse the Docker-builder approach from the deleted work
for Galileo package builds is a decision for section 11.
