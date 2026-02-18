# alloy-host — User Guide

`alloy-host` is the single tool you install on your laptop to create, start, and manage Alloy development environments. It works on macOS, Windows, and Linux.

---

## How it all fits together

When you work with Alloy, three things are involved — but you only ever interact with **one** of them:

```TOML
Your machine                    Inside the VM (automatic)
─────────────────────           ───────────────────────────────
alloy-host  ◄── you run this    alloy-provisioner  ◄── runs itself
    │                               │
    │  starts & manages the VM      │  reads the blueprint and
    │                               │  installs everything
    ▼                               ▼
VirtualBox / WSL2 VM            your dev environment, ready to use
```

**alloy-host** — runs on your machine. You install it once and use it to create and control environments.

**Blueprint** — a recipe that describes a complete development environment for a specific hardware target (e.g. `nordic/nrf91`, `owasys/owa4x`). Blueprints are maintained by the Alloy team and published to a registry. You reference them by name — you never write or edit them.

**alloy-provisioner** — the engine that reads the blueprint and installs everything (compilers, SDKs, tools, environment variables) inside the VM. It is downloaded and run automatically when you start a VM. You never touch it.

**The practical result:** you run `alloy-host init`, `alloy-host up`, and `alloy-host ssh` — and you get a fully configured development environment for your target board, on any OS, with no manual setup.

---

## Documentation

| Guide                                               | What you'll learn                                     |
| --------------------------------------------------- | ----------------------------------------------------- |
| [Installation](installation.md)                     | Install `alloy-host` on macOS, Windows, or Linux      |
| [Your First Environment](your-first-environment.md) | Create and use a dev environment, step by step        |
| [Daily Workflows](daily-workflows.md)               | Start, stop, rebuild, manage multiple environments    |
| [USB Devices](usb-devices.md)                       | Connect hardware (JTAG probes, dev boards) to your VM |
| [Commands](commands.md)                             | Quick reference for every command                     |
| [Troubleshooting](troubleshooting.md)               | Fixes for common problems                             |

---

## At a glance

```bash
# 1. Install alloy-host (see Installation guide for your OS)

# 2. Check everything is ready
alloy-host check-health

# 3. Create an environment for your target board
alloy-host init my-nrf91 --blueprint nordic/nrf91

# 4. Start it (downloads and provisions automatically — takes a few minutes the first time)
alloy-host up my-nrf91

# 5. Open a shell inside the environment
alloy-host ssh my-nrf91

# 6. When done for the day
alloy-host stop my-nrf91
```

Your work inside the VM is saved on a dedicated disk and survives even if you destroy and recreate the VM.
