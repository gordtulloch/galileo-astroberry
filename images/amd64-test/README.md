# amd64 VirtualBox smoke-test ISO

This is a minimal Debian 13 (Trixie) amd64 live/install ISO for validating the
boot and installation path in VirtualBox. It is not the Galileo Linux product
image: it does not include Galileo, the Flask interface, wireless onboarding, or
the product update function. It does include INDI, INDI-3rdparty, and PHD2
(compiled by [scripts/build/](../../scripts/build/)) and a minimal remote desktop.

## Remote desktop

The image runs a virtual display (TigerVNC) with the Openbox window manager as
the `astro` service account. Right-click the desktop for a menu with Galileo,
PHD2, and a terminal. Galileo is not packaged yet; set `GALILEO_COMMAND` in
`/etc/galileo/galileo.conf` once it is installed.

- **Browser (noVNC):** `https://<address>:6080/` - the certificate is
  self-signed, so the browser shows a warning.
- **VNC client:** `<address>:5901`. This port is not encrypted; use it only on
  a trusted network or through an SSH tunnel.
- **Password:** generated randomly on first start. Read it with
  `sudo cat /var/lib/galileo/vnc/password.txt`. To change it, run
  `sudo -u astro sh -c 'vncpasswd -f > /var/lib/galileo/vnc/passwd'`, then
  `sudo systemctl restart galileo-vnc`.

The image includes a live environment and Debian live installer, DHCP/network
tools, OpenSSH server, NetworkManager, and Avahi. Its build-time chroot hook
enables the services and fails the build if `brltty` is installed. A second
check inspects the final ISO package manifest and boot catalog.

## Build with Docker

The first build compiles INDI, INDI-3rdparty, and PHD2 and can take hours and
use several GB of RAM; Docker caches the result, so later ISO builds are fast.
Give Docker Desktop at least 8 GB of memory. Set the `CHANNEL` build argument
to `nightly` to build upstream default branches instead of the pinned stable
releases in `scripts/build/versions.env`.

Docker Desktop must be running, and the host needs network access and at least
20 GB free disk space. From the project root in PowerShell run:

```powershell
.\images\amd64-test\build-iso.ps1
```

The script builds a Debian 13 amd64 builder image, then runs `live-build` in a
privileged Linux container because it creates a chroot and mounts filesystems.
Generated build state remains under `images/amd64-test/`; source configuration
is retained. The final ISO and SHA-256 file are written to `dist/`.

## Automated build

Run the **Build amd64 VirtualBox smoke ISO** GitHub Actions workflow manually
or submit a change to the ISO configuration. The workflow uploads the ISO and
SHA-256 checksum as an artifact.

## VirtualBox validation

1. Create a new Linux/Debian 64-bit VM with at least 2 GB RAM and a 20 GB
   dynamically allocated disk. 4 GB RAM is recommended.
2. Attach the generated ISO as the optical drive and use the default NAT
   network adapter with DHCP enabled.
3. Boot the live system first and verify it reaches a console, receives a
   network address, and resolves network names.
4. Verify the live account can use the console and that SSH, NetworkManager,
   and Avahi are active. The live-build default account is for isolated
   development testing only; do not expose this test image to an untrusted
   network.
5. Select the live installer from the boot menu and install to the VM's
   virtual disk. Reboot without the ISO and verify the installed system boots,
   receives DHCP, and starts SSH.
6. Confirm `brltty` is absent:

   ```sh
   dpkg-query -W brltty
   ```

   The command should report that the package is not installed.

The smoke test checks Debian boot/install, basic networking, SSH availability,
and package selection only. It does not validate physical hardware, Wi-Fi
access-point behavior, or astronomy equipment.
