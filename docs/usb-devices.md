# USB Devices

Connect your hardware — JTAG probes, dev boards, serial adapters — directly to the development VM so you can flash and debug from inside the environment.

---

## How it works

USB passthrough lets the VM "own" a physical USB device connected to your machine. When attached, the device disappears from your host OS and becomes available inside the VM as if it were plugged in directly.

- **VirtualBox backend (macOS, Linux, Windows):** handled by VirtualBox.
- **WSL2 backend (Windows):** handled by [usbipd-win](https://github.com/dorssel/usbipd-win).

---

## Prerequisites

### VirtualBox (macOS / Windows)

No extra setup needed — VirtualBox handles USB passthrough natively.

**Linux only:** your user must be in the `vboxusers` group:

```bash
sudo usermod -aG vboxusers $USER
# Log out and back in
```

### WSL2 (Windows)

Install **usbipd-win:**

```powershell
winget install usbipd
```

Attaching devices for the first time may require an elevated PowerShell session.

---

## See what USB devices are available

```bash
alloy-host usb list
```

Example output:

```TOML
#   NAME                        VENDOR  PRODUCT  ATTACHED TO
1   J-Link Pro                  1366    0101     -
2   Prolific USB-Serial         067b    2303     my-nrf91
3   Nordic nRF52840 DK          1915    521f     -
```

To also show which of those are already attached to a specific VM:

```bash
alloy-host usb list my-nrf91
```

---

## Attach a device to your VM

### Interactive (easiest)

```bash
alloy-host usb attach
```

`alloy-host` will ask you which VM and which device. Good for when you only have one VM or just want a quick pick.

### By device number

```bash
alloy-host usb attach 1 my-nrf91
```

### By device name

```bash
alloy-host usb attach "J-Link Pro" my-nrf91
```

Name matching is case-insensitive. A partial name works too — `"J-Link"` will match `"J-Link Pro"`.

### By UUID or Bus-ID

```bash
# VirtualBox (UUID)
alloy-host usb attach 3a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d my-nrf91

# WSL2 (Bus-ID like 2-3)
alloy-host usb attach 2-3 my-nrf91
```

---

## Detach a device

```bash
alloy-host usb detach "J-Link Pro" my-nrf91
alloy-host usb detach 1 my-nrf91
```

The device returns to your host OS.

---

## Check what's currently attached

```bash
alloy-host usb status
```

Shows all USB devices currently attached to any of your environments (VirtualBox and WSL2 combined).

---

## Typical flashing workflow

```bash
# 1. Plug in your board
# 2. Check it appears
alloy-host usb list my-nrf91

# 3. Attach it to the VM
alloy-host usb attach "J-Link" my-nrf91

# 4. SSH in and flash
alloy-host ssh my-nrf91
# (inside the VM)
west flash
# or: JLinkExe ...

# 5. Detach when done
alloy-host usb detach "J-Link" my-nrf91
```

---

## Troubleshooting

**Device doesn't appear in `usb list`**

Make sure the physical device is connected and recognised by your host OS first:

- macOS: check **System Information → USB**
- Windows: check **Device Manager**
- Linux: run `lsusb`

### **Attachment fails on Linux**

Confirm you're in the `vboxusers` group:

```bash
groups $USER
```

If not, add yourself, log out, and log back in:

```bash
sudo usermod -aG vboxusers $USER
```

**WSL2: `usbipd` command not found**

```powershell
winget install usbipd
```

Make sure PowerShell is restarted after install.

### **Device detaches unexpectedly**

Avoid using a USB hub between the device and your machine. Use a direct port or a powered USB 3.0 hub.
