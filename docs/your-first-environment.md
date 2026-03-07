# Your First Environment

This guide walks you through creating a complete development environment from scratch. By the end, you'll have a running VM with all the tools for your target board installed and ready.

---

## What happens when you create an environment

Before diving in, here's the full picture of what `alloy-host` does on your behalf:

```TOML
You type:                   What actually happens:
──────────────────────────────────────────────────────────────────────
alloy-host init ...    →    Creates a local directory with the VM config
                            Records the blueprint name you chose

alloy-host up ...      →    Starts the virtual machine
                            Downloads alloy-provisioner inside the VM
                            alloy-provisioner fetches the blueprint from
                              the Alloy registry (by name)
                            Installs compilers, SDKs, tools — everything
                              defined by the blueprint
                            VM is ready when this command finishes

alloy-host ssh ...     →    Opens a shell inside the fully configured VM
```

**You only ever type three commands.** The blueprint fetch, provisioner download, package installation, environment setup — all automatic.

---

## Prerequisites

- `alloy-host` installed → [Installation guide](installation.md)
- `alloy-host check-health` reports no errors

---

## Step 1 — Choose a blueprint

A blueprint is a named recipe for a specific hardware target. Your Alloy administrator or team will tell you which blueprint to use. Common examples:

| Blueprint name                        | Target                               |
| ------------------------------------- | ------------------------------------ |
| `nordic/nrf91`                        | Nordic nRF9160 (cellular IoT)        |
| `nordic/nrf52`                        | Nordic nRF52 series                  |
| `nordic/nrf54`                        | Nordic nRF54 series                  |
| `espressif/esp32-idf`                 | Espressif ESP32 (ESP-IDF)            |
| `st/stm32-cube-gcc`                   | ST STM32 (ARM GCC + OpenOCD)         |
| `st/stm32mp157-dk2`                   | ST STM32MP157-DK2 (embedded Linux)   |
| `raspberry-pi/rp2040`                 | Raspberry Pi Pico / RP2040           |
| `raspberry-pi/raspberry-pi-4-model-b` | Raspberry Pi 4 Model B               |
| `raspberry-pi/raspberry-pi-5`         | Raspberry Pi 5                       |
| `beagleboard/beaglebone-black`        | BeagleBone Black (AM335x)            |
| `nxp/imx8mplus-evk`                   | NXP i.MX 8M Plus EVK (Yocto)         |
| `nvidia/jetson-nano`                  | NVIDIA Jetson Nano                   |
| `generic/yocto-image-builder`         | Generic Yocto/Kas image builder      |
| `generic/buildroot-image-builder`     | Generic Buildroot image builder      |
| `generic/zephyr`                      | Generic Zephyr RTOS (board-agnostic) |

---

## Step 2 — Initialize the environment

```bash
alloy-host init my-nrf91 --blueprint nordic/nrf91
```

Replace `my-nrf91` with any name you like — it's just the local directory name. Replace `nordic/nrf91` with your blueprint.

This is instant. It creates the directory and records your choice — it does not start a VM or download anything yet.

```TOML
my-nrf91/
├── Vagrantfile        ← VM configuration (do not edit)
├── home-data.vdi      ← your persistent data disk (created empty, 10 GB)
└── scripts/
    └── bootstrap.sh   ← provisioning entry point (do not edit)
```

> **Your work is stored on `home-data.vdi`.** This virtual disk is mounted as `/home/vagrant` inside the VM. It survives if you destroy and recreate the VM — your code, build artifacts, and settings are always safe.

---

## Step 3 — Start and provision

```bash
alloy-host up my-nrf91
```

The first run takes several minutes — it is downloading the base VM image and all the development tools defined by your blueprint. Subsequent starts (after a `stop`) are fast because everything is already installed.

What you'll see:

```TOML
==> Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box ...
==> default: Booting VM...
[...]
==> default: Running provisioner: shell...
    default: Downloading alloy-provisioner...
    default: Installing blueprint nordic/nrf91...
    default: [1/12] Installing system packages...
    default: [2/12] Installing ARM GNU Toolchain...
    [...]
    default: Environment ready.
```

When the command returns to your prompt, the VM is fully provisioned and ready.

---

## Step 4 — Open a shell

```bash
alloy-host ssh my-nrf91
```

You are now inside the development environment. The compilers, SDKs, and tools are all on the `PATH`. You can build firmware, flash devices, run debuggers — everything the blueprint installed is available.

```bash
# Example: check what's available
arm-none-linux-gnueabihf-gcc --version
west --version
nrfjprog --version
```

---

## Step 5 — Stop when done

```bash
alloy-host stop my-nrf91
```

The VM halts. Your work inside `/home/vagrant` is saved on `home-data.vdi`. Nothing is lost.

To resume:

```bash
alloy-host up my-nrf91
alloy-host ssh my-nrf91
```

---

## Running without `cd`

You can manage any environment by name from anywhere on your machine — no need to `cd` into the directory first:

```bash
alloy-host up my-nrf91
alloy-host ssh my-nrf91
alloy-host stop my-nrf91
```

Or if you're already inside the directory, you can omit the name:

```bash
cd my-nrf91
alloy-host up
alloy-host ssh
```

---

## Windows — WSL2 backend

On Windows, you can use WSL2 instead of VirtualBox. Add `--backend wsl2` to the `init` command:

```bash
alloy-host init my-nrf91 --blueprint nordic/nrf91 --backend wsl2
```

You'll be prompted to choose a Linux username (default: `ubuntu`). Everything else — `up`, `ssh`, `stop`, `destroy` — works exactly the same way.

**WSL2 requirements:** WSL2 must be enabled (`wsl --install` in an elevated PowerShell). For USB device passthrough to WSL2, also install [usbipd-win](https://github.com/dorssel/usbipd-win).

---

## What the blueprint installs

You don't need to know the details, but it helps to understand the concept:

A blueprint is a set of YAML files maintained by the Alloy team that lists everything needed for a target board:

- System packages (build tools, libraries)
- Cross-compilers and toolchains (e.g. ARM GNU Toolchain)
- Vendor SDKs (e.g. nRF Connect SDK, Zephyr)
- Environment variables (cross-compile prefix, SDK paths)
- Custom scripts

The blueprint is versioned and published to the Alloy registry. When you run `alloy-host up`, the `alloy-provisioner` agent inside the VM fetches the exact version of the blueprint and applies it. **You never download, edit, or manage blueprint files yourself.**

---

## Next steps

- [Daily Workflows](daily-workflows.md) — rebuild environments, manage multiple VMs
- [USB Devices](usb-devices.md) — connect your hardware board to the VM
- [Commands](commands.md) — quick reference for all commands
