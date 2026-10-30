# Galileo Linux

Galileo Linux is a planned Debian-based operating system for running the Galileo
imaging system and INDI on Raspberry Pi 4 and newer devices and 64-bit amd64
computers. The system is designed to run without a local display, keyboard, or
mouse, with a Flask-based web interface as the primary way to set up and
operate the system. PHD2 and the Galileo desktop application run in a minimal
remote desktop reached over VNC or from a browser through noVNC. SSH is
available for administration and recovery.

## Project status

The project is at the initial scope stage. A Docker-based amd64 Debian
live/install ISO build workflow for VirtualBox smoke testing is defined under
[`images/amd64-test/`](images/amd64-test/), but its first image has not yet been
built or validated. The product operating system, Flask interface, Galileo and
INDI integration, and Raspberry Pi image are not yet implemented.

## Supported targets

- Raspberry Pi 4 and newer models, using 64-bit ARM Debian.
- 64-bit amd64 computers.
- A bootable ISO for 64-bit amd64 computers, testable in Oracle VirtualBox.
- A Raspberry Pi disk image intended to be written to a microSD card with
  Raspberry Pi Imager. This is a raw disk image, not an ISO.
- Operation without a locally attached display: web-based setup, a minimal
  VNC/noVNC remote desktop for PHD2 and Galileo, and SSH access.
- A first-boot Wi-Fi setup SSID and fallback hotspot when no configured local
  Wi-Fi network is available.
- The default network name `galileo.local`, changeable from the web interface.
- `brltty` is excluded because it can interfere with serial-over-USB devices.

## Planned capabilities

- Debian-based bootable operating system images for the supported targets.
- Galileo, INDI, and INDI-3rdparty drivers, with compatible stable builds by
  default. Users may select nightly builds for the next manually run update;
  selecting that channel does not schedule or start an update.
- A Flask web interface for system setup, INDI driver loading and configuration,
  and Galileo imaging workflows.
- Web-based Wi-Fi onboarding, fallback hotspot, and device-name configuration.
- A user-invoked update function that retrieves project source code with Git
  and builds applicable components; normal Debian operating-system packages
  are installed and updated through APT.
- Managed updates, persistent user data, recovery procedures, and documented
  installation and administration.

The [amd64 VirtualBox smoke ISO](images/amd64-test/README.md) contains Debian,
network tools, SSH, the live installer, INDI, INDI-3rdparty, PHD2, and the
VNC/noVNC desktop. It does not yet contain Galileo or the Flask interface and is
not the Galileo Linux product image.

## Project scope

See the [Project Scope Document](docs/PSD.md) for goals, requirements,
deliverables, feasibility risks, and acceptance criteria.

## Review questions

Please review the scope, especially:

1. The distinct boot artifact formats: amd64 ISO and Raspberry Pi Imager disk
   image.
2. The web-first user experience and the boundary between the Flask interface
   and Galileo's existing application.
3. The proposed stable/nightly INDI update behavior and Galileo source update
   trigger.
