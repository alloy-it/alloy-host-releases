# Troubleshooting

Solutions to the most common problems.

---

## Installation issues

### `alloy-host: command not found`

The binary is not in your `PATH`.

**macOS / Linux:** Move it to `/usr/local/bin/`:

```bash
sudo mv alloy-host /usr/local/bin/
```

**Windows:** Add the folder containing `alloy-host.exe` to your user `PATH` in **System Properties → Environment Variables**.

---

### `check-health` reports Vagrant or VirtualBox not found

**Most common cause:** the tool was not installed, or it's installed in a non-standard location.

1. Verify the tool is installed by running it directly:

   ```bash
   vagrant --version
   VBoxManage --version
   ```

2. If it runs but `alloy-host` doesn't find it, set the path explicitly:

   ```bash
   alloy-host config set vagrant-path /full/path/to/vagrant
   alloy-host config set vbox-manage-path /full/path/to/VBoxManage
   ```

3. On macOS with Homebrew, VBoxManage is typically at:
   `/Applications/VirtualBox.app/Contents/MacOS/VBoxManage`

---

## `alloy-host up` issues

### The VM starts but provisioning fails

The provisioner downloads from the internet during `alloy-host up`. Check:

1. **Internet access** — the guest VM needs to reach the Alloy registry and external package servers. If you're behind a proxy or firewall, your network team may need to whitelist those hosts.

2. **Disk space** — the first run downloads and installs several GB of tools. Make sure your machine has at least 20 GB free.

3. **Re-try** — run `alloy-host provision my-vm` to re-run provisioning without destroying the VM. The provisioner is idempotent and will pick up where it left off.

---

### `vagrant up` times out or hangs on "Waiting for machine to boot"

This is usually a VirtualBox issue on the host.

1. Make sure VirtualBox is fully installed and not in a broken state. Open the VirtualBox GUI and check that it launches without errors.

2. Ensure VirtualBox kernel extensions are loaded:
   - **macOS:** go to **System Settings → Privacy & Security** and approve the VirtualBox kernel extension if prompted.
   - **Linux:** run `sudo modprobe vboxdrv`.

3. Restart your machine and try again.

---

### `alloy-host up` fails with "directory already exists"

You already initialised an environment with that name. Either use a different name, or if the existing environment is broken:

```bash
alloy-host destroy my-vm --all   # wipe it completely
alloy-host init my-vm --blueprint nordic/nrf91
```

---

## macOS — Apple Silicon (M1/M2/M3) issues

VirtualBox support for Apple Silicon is experimental. If `alloy-host up` fails:

1. Make sure you have **VirtualBox 7.1 or later** — it has the best ARM Mac support.
2. Approve the VirtualBox system extension in **System Settings → Privacy & Security** after installation.
3. If VirtualBox continues to be unstable, contact your Alloy administrator — a different base box or configuration may be available for your target.

---

## SSH issues

### `alloy-host ssh` says "VM is not running"

Start the VM first:

```bash
alloy-host up my-vm
alloy-host ssh my-vm
```

### SSH connection is refused or times out

1. Make sure the VM is fully started — wait for `alloy-host up` to complete before running `ssh`.
2. Run `alloy-host stop my-vm` followed by `alloy-host up my-vm` to restart cleanly.

---

## USB device issues

### Device not appearing in `usb list`

1. Unplug and replug the device.
2. Confirm the host OS recognises it:
   - macOS: **System Information → USB**
   - Windows: **Device Manager**
   - Linux: `lsusb`

### Attachment fails on Linux

Your user needs to be in the `vboxusers` group:

```bash
groups $USER       # check if vboxusers is listed
sudo usermod -aG vboxusers $USER
# Log out and back in
```

### WSL2: attachment fails or `usbipd` not found

```powershell
winget install usbipd
```

Open a new PowerShell after installation. For stubborn cases, try running the attach from an **elevated** PowerShell session.

---

## Environment registry issues

### `alloy-host list` shows an environment but it no longer exists on disk

If you deleted the environment directory manually (outside of `alloy-host destroy`), the registry entry becomes stale. It doesn't affect anything, but if it bothers you, you can edit `~/.alloy-it/vm/vms.yaml` and remove the stale entry.

---

## Getting more help

Run any command with `--help` for usage details:

```bash
alloy-host --help
alloy-host up --help
alloy-host usb --help
```

If the issue persists, contact your Alloy administrator with the full output of:

```bash
alloy-host --version
alloy-host check-health
```
