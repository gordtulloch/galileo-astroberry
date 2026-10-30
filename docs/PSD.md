# Galileo Linux Project Scope Document

## 1. Purpose

Galileo Linux will provide a Debian-based operating system for running the
Galileo imaging system and INDI on Raspberry Pi 4 and newer models and on
64-bit amd64 computers. Users should be able to install, configure,
and operate the system through a Flask-based web interface without needing a
local monitor, keyboard, or mouse. Graphical astronomy applications that have
no web equivalent, initially PHD2 and the Galileo desktop application, run in a
minimal remote desktop that is reached over VNC or from a browser through
noVNC. SSH will remain available for administration and recovery.

This document records the initial product scope and the decisions that must be
validated before implementation. It is a project definition, not a claim that
the image, web interface, or operating system integration already exists.

## 2. Vision and goals

1. Deliver a dependable, bootable Debian-based system for dedicated Galileo
   imaging hosts.
2. Support Raspberry Pi 4 and newer Raspberry Pi models, and 64-bit amd64
   computers.
3. Make the Flask web interface the primary access method for setup,
   configuration, and imaging tasks.
4. Operate without a locally attached display, keyboard, or mouse. The Flask
   web interface is primary; a minimal remote desktop (VNC and noVNC) hosts the
   graphical applications that need one; SSH is available as a secondary
   administrative and recovery interface.
5. Include both INDI and INDI-3rdparty, install their latest compatible stable
   builds by default, and let the administrator opt into nightly builds.
6. Provide an end-user-invoked update function that retrieves project source
   code with Git and builds all applicable project components. Install normal
   Debian operating-system package updates through APT.
7. Provide repeatable builds, documented updates, and recovery procedures for
   both hardware families.

## 3. Scope

### 3.1 In scope

- A Debian-based operating system image and build/release process.
- 64-bit ARM support for Raspberry Pi 4 and newer models.
- 64-bit amd64 support.
- A bootable amd64 ISO, usable both for installation on compatible computers
  and for testing the system in Oracle VirtualBox.
- A Raspberry Pi disk image that can be written to a microSD card with
  Raspberry Pi Imager. This is a device boot image, not an ISO.
- First-boot provisioning, network setup, device permissions, persistent
  storage, and remote administration.
- A minimal graphical environment that runs on a virtual display and is
  reachable only remotely through VNC and a browser-based noVNC client. It
  contains just enough to run PHD2 and the Galileo desktop application.
- Build scripts that compile INDI, INDI-3rdparty, and PHD2 from upstream
  source, used both to build the image and, later, by the update function.
- A first-boot wireless setup SSID, web-based connection to a local Wi-Fi
  network, and a fallback hotspot when no configured local Wi-Fi network is
  available.
- A default network name of `galileo.local`, configurable through the web UI.
- Installation and lifecycle management for Galileo, INDI, INDI-3rdparty and
  its drivers, the Flask web application, and their required dependencies.
- A Flask web interface that is the primary user interface for system
  administration, device/driver management, and Galileo imaging workflows.
- INDI driver discovery, loading/unloading, profiles, connection state, and
  configuration presented in a tabbed layout comparable in function to the
  KStars/EKOS driver configuration screen.
- An administrator-controlled INDI update channel: compatible stable builds
  by default, or nightly builds when selected. The selected channel is used the
  next time the user runs the update function.
- A user-invoked update function that retrieves project source code with Git
  and builds all applicable project components.
- A separate APT-based path for normal Debian operating-system package
  installation and updates.
- Exclude the `brltty` package and service from the image and installation
  dependencies because it can interfere with serial-over-USB astronomy
  devices.
- Update status, failure reporting, rollback/recovery strategy, logs, and
  version identification.
- Documentation, automated validation, and representative hardware testing.

### 3.2 Out of scope for the initial release

- Supporting Raspberry Pi models earlier than Raspberry Pi 4.
- 32-bit operating systems or 32-bit amd64 installations.
- Replacing or modifying upstream INDI drivers beyond integration and
  packaging needed for the supported devices.
- A guarantee that every INDI driver or astronomy peripheral works on every
  supported computer. Supported hardware and driver combinations will be
  documented and tested incrementally.
- Scheduled or unattended INDI/INDI-3rdparty upgrades. The user selects the
  stable or nightly channel, then manually runs the update function to download
  and install the corresponding builds.
- Promising that upstream Galileo `main` is production-stable. Source mode is
  an opt-in track and must identify the installed commit/version.
- Requiring a locally attached display for normal operation. The image
  provides a virtual display only; a physical-display desktop is not provided.
- A full desktop environment, desktop applications beyond PHD2, Galileo, and a
  terminal, or session management for multiple desktop users.

## 4. Users and primary use cases

### 4.1 Users

- **Observatory/imaging operator:** configures equipment and runs imaging from
  a browser on the local network.
- **System administrator:** provisions networking, updates software, manages
  access, and diagnoses or recovers the host, primarily through the web UI and
  secondarily over SSH.
- **Developer/tester:** selects Galileo source mode or INDI nightly builds to
  validate changes and report compatibility issues.

### 4.2 Key use cases

1. Write the amd64 ISO to suitable boot media or write the Raspberry Pi disk
   image to a microSD card with Raspberry Pi Imager, boot the target, connect
   to its setup SSID, and complete first-run setup from a browser.
2. Use the web UI to connect the device to a local Wi-Fi network. If no
   configured local network is available, connect to the device's hotspot and
   continue using the web UI.
3. Reach the web UI at `http://galileo.local` by default, or use the configured
   device name after changing it in the web interface.
4. Select the stable or nightly INDI/INDI-3rdparty channel, then run the
   update function to retrieve and install builds from that channel; inspect
   installed versions and update results.
5. Discover available INDI drivers, load a driver/profile, connect equipment,
   and configure device properties through tabs and suitable controls.
6. Open Galileo and carry out supported imaging workflows through the
   browser-based primary interface.
7. Open the remote desktop in a browser (noVNC) or a VNC client to run PHD2
   guiding and, until the web interface covers it, the Galileo desktop
   application.
8. Choose Galileo's packaged/release installation or source mode, then invoke
   the update function to retrieve the applicable source code with Git and
   build updated project components.
9. Diagnose a failed service or update through visible status/logs and recover
   through documented web or SSH steps.

## 5. Product requirements

### 5.1 Platform and boot

- **PLAT-01:** Produce 64-bit ARM builds for Raspberry Pi 4 and newer models
  that can run the selected Debian base.
- **PLAT-02:** Produce 64-bit amd64 builds that boot on supported
  UEFI/BIOS-class systems as explicitly documented by the project.
- **PLAT-03:** Deliver a bootable 64-bit amd64 ISO that can be installed on
  supported physical computers and booted as a VirtualBox virtual machine for
  development and testing.
- **PLAT-04:** Deliver a Raspberry Pi disk image suitable for writing to
  microSD with Raspberry Pi Imager. Do not label this image as an ISO.
- **PLAT-05:** The system must complete boot and expose setup/diagnostic access
  without a locally connected display. The remote desktop described in section
  5.6 starts on a virtual display and must not require a physical one.
- **PLAT-06:** Do not install or enable `brltty`; ensure image packages and
  dependency selections do not introduce it. Validate serial-over-USB device
  access with supported INDI equipment.

### 5.2 Web interface and remote operation

- **WEB-01:** The Flask-based web UI is the primary interface for supported
  setup, administration, device management, and Galileo imaging workflows.
- **WEB-02:** The UI must report service state, software versions, update state,
  and actionable errors rather than presenting a success state when an
  operation failed.
- **WEB-03:** Provide accessible network setup and first-run onboarding without
  requiring a local display.
- **WEB-04:** Keep SSH available for administrative access and recovery; SSH
  does not replace the web-first normal workflow.
- **WEB-10:** Where a task requires a graphical application that the web UI
  does not replace (initially PHD2 and the Galileo desktop application), the
  web UI must link to the remote desktop (section 5.6) rather than leave the
  user to find its address.
- **WEB-05:** Document authentication, authorization, network exposure, and
  secure defaults before making the UI remotely reachable.
- **WEB-06:** On first boot, advertise a wireless setup SSID that lets a user
  connect from a phone or computer and reach the web-based onboarding flow
  without an existing local network or attached display.
- **WEB-07:** Provide a web interface function to configure and connect to a
  local Wi-Fi network. If no configured local Wi-Fi network is available, the
  device must provide a wireless hotspot so the user can continue to access
  the web UI.
- **WEB-08:** Use `galileo.local` as the default device network name and allow
  the user to change it through the web UI. Apply the change to the system
  hostname and network discovery, report errors, and show the updated address
  and reconnection guidance.
- **WEB-09:** Provide a documented way to reach the web UI when local
  `.local`/mDNS name resolution is unavailable, such as displaying the current
  IP address on the setup page or onboarding instructions.

### 5.3 INDI and equipment management

- **INDI-01:** Install the latest stable INDI build available for the selected
  Debian release and target architecture by default, together with the latest
  compatible stable INDI-3rdparty build and its drivers.
- **INDI-02:** Let an administrator select the INDI/INDI-3rdparty update
  channel: stable by default or nightly. Persist the selection and use it the
  next time the user manually runs the update function; selecting nightly must
  not itself download or install updates. Clearly mark the selected channel
  and installed versions and explain nightly's pre-release risk.
- **INDI-03:** Expose the INDI server and supported driver lifecycle through the
  Flask UI, including discovery, load/unload, profiles, connection status, and
  configuration.
- **INDI-04:** Present device configuration in a tabbed layout. Map INDI
  property types to appropriate controls and distinguish read-only,
  unsupported, and unavailable properties.
- **INDI-05:** Persist selected profiles and configuration across reboot, with
  explicit handling for device-specific values and configuration errors.
- **INDI-06:** Keep INDI and INDI-3rdparty versions compatible when installing
  or upgrading. The update function must use the persisted channel selection
  for both components, surface failures, and provide a documented recovery
  path, including returning to stable on a subsequent user-invoked update when
  technically supported.

### 5.4 Galileo installation and updates

- **GAL-01:** Provide a supported Galileo installation compatible with both
  target architectures and the selected Debian base.
- **GAL-02:** Provide an optional source installation based on the upstream
  Galileo repository's `main` branch.
- **GAL-03:** Provide an end-user-invoked update function that retrieves new
  project source code using Git and builds all applicable project components.
  Identify the repositories, branches/commits, and components included in an
  update, and report progress and results in the web UI.
- **GAL-04:** In Galileo source mode, the update function must synchronize from
  upstream `main` when a new Galileo version update is available, then report
  the resulting version/commit and update outcome in the web UI. Source updates
  are user initiated, not unattended background updates.
- **GAL-05:** Use APT to install and update normal Debian operating-system
  packages. Clearly distinguish APT-managed OS packages from source components
  retrieved and built by the project update function.
- **GAL-06:** Do not replace a working installation or user data with a
  partially applied update. Define and test rollback/recovery before enabling
  updates.
- **GAL-07:** Keep user settings, equipment profiles, and image data outside
  disposable application/build directories and preserve them through upgrades.

### 5.5 Operations, security, and maintainability

- **OPS-01:** Use managed services with explicit startup ordering, health
  reporting, restart policy, and useful logs.
- **OPS-02:** Define least-privilege service accounts and device access; do not
  run the web application with unnecessary system privileges.
- **OPS-03:** Provide authenticated controls for actions that change software,
  services, drivers, or equipment configuration.
- **OPS-04:** Document backup, restore, update, rollback, and factory-recovery
  behavior.
- **OPS-05:** Report update progress and failures in the web UI, including Git
  retrieval, build, installation, service restart, and APT operation outcomes;
  retain useful logs and installed version/commit information.
- **OPS-06:** Identify the Debian, INDI, Galileo, Flask, and other component
  versions in each release and include applicable license notices.
- **OPS-07:** Build artifacts reproducibly enough to trace a released image to
  its source revision, package versions, and build configuration.

### 5.6 Remote desktop

- **DESK-01:** Provide a minimal graphical session (virtual X display and
  lightweight window manager) containing only what is needed to run PHD2, the
  Galileo desktop application, and a terminal. It starts at boot without a
  physical display or login.
- **DESK-02:** Offer the session over VNC (TCP 5901) and through a noVNC web
  client served by the device (HTTPS, TCP 6080) so that a browser alone is
  enough to reach it.
- **DESK-03:** Require a password for every VNC and noVNC connection. Generate
  a random password per installation rather than shipping a fixed default, and
  document how an administrator retrieves and changes it.
- **DESK-04:** Encrypt browser access. noVNC is served over TLS; the raw VNC
  port uses VNC authentication without transport encryption and must be
  documented as suitable only for trusted networks or SSH tunnels. Provide a
  way to disable it.
- **DESK-05:** Run the desktop session as a dedicated, non-login service
  account with only the device-group access it needs (serial, USB, video),
  not as root and not as the administrator's account.
- **DESK-06:** Build INDI, INDI-3rdparty, and PHD2 with scripts that support the
  stable and nightly channels, record the built source revisions on the
  device, and install runtime libraries only, not build tools or headers.
  PHD2 connects to the INDI server on the same device.
- **DESK-07:** Document that Galileo is a desktop application: until the
  browser-first interface is complete (M4), it runs inside this desktop.

## 6. Proposed system components

The implementation should validate this division of responsibilities before
coding:

- **Debian base and boot configuration:** architecture-specific boot support,
  kernel/firmware, package repositories, users, and first-boot provisioning.
- **Astronomy software:** INDI server and INDI-3rdparty driver builds, with
  matched stable/nightly channels and recorded upstream versions.
- **System services:** INDI server and drivers, Flask web application, Galileo
  runtime, update service, and health/log reporting.
- **Remote desktop:** TigerVNC virtual X server, Openbox, and a noVNC/websockify
  web client, running PHD2 and the Galileo desktop application.
- **Flask control plane:** browser-facing setup and administration APIs,
  authentication, driver management, INDI property display/editing, and
  Galileo operations, including the user-triggered source update workflow.
- **Galileo application:** reuse the existing Galileo capabilities and device
  integration where possible; determine the implementation path for a
  browser-first interface rather than assuming the current desktop UI is
  already a Flask/web application.
- **Persistent data:** separate operating-system/application files from user
  settings, device profiles, and captured images.

The boundary between Flask and Galileo is a design decision: the web layer
should call a defined application/service interface rather than directly
mutating internal application state or presenting a misleading subset of
Galileo functionality.

## 7. Deliverables

1. Approved requirements and architecture, including the target-specific boot
   artifact formats.
2. Automated image build definitions for ARM64 and amd64.
3. A bootable amd64 ISO, validated in VirtualBox, and a Raspberry Pi
   Imager-compatible disk image.
4. Debian packaging/install integration for Galileo, INDI and INDI-3rdparty
   stable/nightly builds and drivers, and the Flask web application.
5. First-boot wireless setup SSID, local Wi-Fi onboarding, fallback hotspot,
   and web-configurable `galileo.local` device name.
6. Web-first setup, system management, INDI driver configuration, and Galileo
   imaging experience.
7. User-triggered Git retrieval and source-build update tooling, APT-based
   operating-system package updates, persistent-data policy, and recovery.
8. Automated test suite, hardware validation matrix, release artifacts, and
   user/administrator documentation.

## 8. Constraints, assumptions, and risks

### 8.1 Raspberry Pi disk image

The Raspberry Pi deliverable is a device disk image intended to be written to a
microSD card using Raspberry Pi Imager, following the normal Raspberry Pi
installation workflow. It is not an ISO. Validate the image's boot partition,
firmware/kernel support, first-boot provisioning, and Raspberry Pi Imager
compatibility on representative supported models.

### 8.2 Wireless onboarding and device naming

The device must expose a wireless setup network on first boot and a hotspot
when it cannot connect to a configured local Wi-Fi network. The user reaches
the Flask UI through this wireless path to configure the local network and
device name. `galileo.local` is the default name. mDNS name resolution depends
on the connecting client and network, so onboarding must also explain an
IP-address-based way to reach the UI when the `.local` name does not resolve.

Wi-Fi access-point capability depends on compatible wireless hardware and
drivers, particularly on amd64 computers. The supported hardware requirements
must identify this prerequisite and provide a recovery/access path for systems
without compatible Wi-Fi hardware. The setup SSID name, credential/provisioning
method, hotspot transition behavior, and whether the setup network remains
available after joining a local network are design decisions to settle before
implementation. Do not ship an open, unauthenticated setup network without an
explicit security review and documented risk acceptance.

### 8.3 Other constraints and risks

- **Debian and upstream availability:** the latest compatible stable INDI and
  INDI-3rdparty releases and driver availability may vary by Debian release
  and architecture. Packaging from upstream source may be needed and must be
  versioned and tested together.
- **Nightly regressions:** nightly builds can break device support or
  configuration. Stable remains the default; nightly must be an explicit
  opt-in with a recovery path.
- **Galileo UI gap:** Galileo's existing application is a cross-platform
  PySide6 desktop application. The requirement for Flask as the primary UI for
  all tasks requires an integration or web-interface strategy and may involve
  substantial feature work.
- **Galileo source update policy:** upstream `main` can change independently
  of a published Galileo version. Define how the user-triggered updater
  identifies a published Galileo version update, selects Git branches/commits,
  builds components, and preserves a recoverable working version.
- **Source build updates:** retrieving and building all applicable components
  can take time and may fail because of upstream changes, build dependencies,
  or architecture differences. The update must report progress/errors and
  preserve a recoverable working version.
- **APT and source update separation:** define which software is updated via
  Debian package repositories and which source components are retrieved and
  built by the project updater. Avoid applying conflicting updates to the same
  component through both mechanisms.
- **Hardware variability:** USB bandwidth, camera drivers, power, storage,
  network interfaces, wireless access-point support, and boot firmware vary by
  device and model.
- **Remote administration exposure:** an imaging controller can operate
  physical equipment. Authentication, authorization, secure transport, and
  network exposure are required design concerns.
- **Data volume and durability:** captured images can consume substantial
  storage; storage selection, capacity reporting, backup, and upgrade
  preservation must be specified.

## 9. Milestones and completion criteria

### M1 — Requirements and feasibility

- Confirm supported Raspberry Pi models and the Debian base.
- Validate the Raspberry Pi Imager disk-image workflow on representative
  supported models.
- Validate first-boot wireless onboarding, local Wi-Fi setup, hotspot fallback,
  and access on representative Pi and amd64 wireless adapters.
- Define the Galileo web-interface approach, INDI package source/version
  policy, Git source update selection/build process, APT update behavior, and
  security model.

### M2 — Build and boot foundation

- Build amd64 and ARM64 artifacts automatically.
- Boot the amd64 ISO in Oracle VirtualBox and validate installation/first boot,
  core services, web access, and update behavior in a documented VM profile.
- Boot each artifact on representative hardware, provision a network
  connection using the wireless setup SSID or wired fallback, and reach
  documented remote administration.
- Verify system identity, logs, and persistent storage.

### M3 — Services and device management

- Install Galileo and INDI services on both target classes.
- Demonstrate compatible INDI and INDI-3rdparty stable defaults, nightly
  opt-in, service health, driver discovery, load/unload, saved profiles, and
  property configuration.
- Validate with representative supported INDI devices or maintained test
  fixtures where physical devices are unavailable.

### M4 — Web-first Galileo operation

- Complete the agreed primary Galileo imaging tasks in the Flask UI.
- Demonstrate the full supported flow without a local display.
- Validate reconnect, error reporting, and persistence after reboot.

### M5 — Updates, recovery, and release

- Verify compatible stable/nightly INDI and INDI-3rdparty channel behavior and
  recovery.
- Verify the user-triggered update retrieves the expected Git revisions,
  builds applicable components, reports progress/results, preserves user data,
  and recovers from a failed update.
- Verify APT installs and updates normal Debian operating-system packages
  independently of source-component builds.
- Publish tested artifacts, checksums/version metadata, installation steps,
  supported hardware list, known issues, and backup/recovery instructions.

## 10. Acceptance criteria

The initial release is acceptable only when:

1. The agreed boot artifact for each supported target can be installed and
   repeatedly boots: the amd64 ISO in Oracle VirtualBox and on representative
   physical hardware, and the Raspberry Pi Imager-compatible microSD disk
   image on representative Pi hardware.
2. A user can complete first-run setup and normal supported operation without
   attaching a display: connect to the first-boot setup SSID, configure local
   Wi-Fi through the Flask UI, and continue through the hotspot if the
   configured network is unavailable.
3. SSH is available through documented, secure administrative/recovery
   procedures.
4. The device is reachable as `galileo.local` by default, the name can be
   changed through the web UI, and users have documented fallback access when
   `.local` resolution is unavailable.
5. Galileo, INDI, and INDI-3rdparty install and start on both architectures;
   the selected drivers are available and service/device errors are visible.
6. Stable is the default INDI/INDI-3rdparty update channel; an administrator
   can select nightly, and the next manually invoked update installs compatible
   nightly builds. The selected channel and active versions are visible, and
   selecting a channel alone does not start an update.
7. Users can load and configure supported INDI drivers using the tabbed UI,
   and saved profiles/configuration survive reboot.
8. The agreed core Galileo imaging tasks can be completed in the primary web
   interface without depending on the local desktop UI.
9. A user can invoke the update function to retrieve designated source
   revisions with Git, build applicable project components, and see progress,
   result, and installed version/commit. Galileo source mode follows the
   defined `main` update policy.
10. Updates and reboot preserve user configuration and images; documented
   recovery succeeds in validation.
11. Normal Debian operating-system package updates are handled through APT and
    are distinguishable from Git-based source builds.
12. `brltty` is absent and not enabled in released images, and supported
    serial-over-USB astronomy devices can be accessed without interference
    from it.
13. Each release has traceable build inputs, test results, checksums, and
    installation, security, update, and recovery documentation.

## 11. Decisions requiring review

- Define the exact supported Pi models from Raspberry Pi 4 onward, including how
  future models enter the support matrix.
- Select the Debian release, image-build system, and supported BIOS/UEFI
  behavior on amd64.
- Decide the Galileo web-interface integration strategy and which workflows
  must be available in the initial release.
- Define what event constitutes a “Galileo version update,” how the user
  update function identifies it, which Git branch/commit it retrieves, and
  what source components it rebuilds.
- Define whether the update function also offers a separate user-triggered APT
  package upgrade or leaves Debian package upgrades to the operating-system
  update mechanism.
- Identify the upstream source and packaging strategy for compatible stable
  and nightly INDI and INDI-3rdparty builds on both architectures, including
  which third-party drivers are included by default.
- Set network access defaults, authentication method, and whether remote
  access beyond the local network is supported.
- Define the setup SSID, secure credential/provisioning method, fallback
  hotspot state transition, supported Wi-Fi hardware requirements, and
  behavior after the device joins a local network.
- Define hostname validation/uniqueness rules and the fallback method for
  reaching the web UI when mDNS is unavailable.
- Define storage layout, backup expectations, and update rollback guarantees.
