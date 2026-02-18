# Commands

Quick reference for every `alloy-host` command.

For all commands, `[vm-name]` is optional when you are already inside the environment directory. Pass it to control an environment from anywhere on your machine.

---

## Environment lifecycle

### `init`

Create a new development environment.

```bash
alloy-host init <name> --blueprint <vendor/board>
```

| Flag                | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| `--blueprint`, `-b` | Blueprint to use, e.g. `nordic/nrf91` **(required)**                  |
| `--backend`         | `vm` (VirtualBox, default) or `wsl2` (Windows only)                   |
| `--wsl-user`        | Linux username for WSL2 distro (default: prompted, fallback `ubuntu`) |

```bash
alloy-host init my-nrf91 --blueprint nordic/nrf91
alloy-host init my-nrf91 --blueprint nordic/nrf91 --backend wsl2
```

---

### `up`

Start and provision the environment.

```bash
alloy-host up [vm-name]
```

First run downloads the VM image and all tools — this takes several minutes. Subsequent starts are fast.

---

### `provision`

Re-run provisioning on a running environment (apply blueprint updates).

```bash
alloy-host provision [vm-name]
```

---

### `ssh`

Open an interactive shell inside the environment.

```bash
alloy-host ssh [vm-name]
```

---

### `stop`

Halt the environment. Your work is saved.

```bash
alloy-host stop [vm-name]
```

---

### `destroy`

Remove the VM. The persistent data disk (your files) is preserved by default.

```bash
alloy-host destroy [vm-name]           # remove VM, keep data
alloy-host destroy [vm-name] --all     # remove VM and all data (irreversible)
```

---

## Information

### `list`

Show all registered environments and their status.

```bash
alloy-host list
```

### `check-health`

Verify that Vagrant and VirtualBox are installed and reachable.

```bash
alloy-host check-health
```

---

## Configuration

### `config show`

Display the current configuration (custom tool paths, etc.).

```bash
alloy-host config show
```

### `config set`

Override the path to Vagrant or VBoxManage.

```bash
alloy-host config set vagrant-path /opt/vagrant/bin/vagrant
alloy-host config set vbox-manage-path /opt/VirtualBox/VBoxManage
```

### `config unset`

Remove a path override and revert to automatic detection.

```bash
alloy-host config unset vagrant-path
alloy-host config unset vbox-manage-path
```

---

## USB devices

### `usb list`

List USB devices on the host, with attachment status.

```bash
alloy-host usb list [vm-name]
```

### `usb attach`

Attach a USB device to an environment. Device can be specified by number, name, or UUID/Bus-ID.

```bash
alloy-host usb attach                          # interactive
alloy-host usb attach 1 [vm-name]             # by number
alloy-host usb attach "J-Link" [vm-name]      # by name
```

### `usb detach`

Detach a USB device from an environment.

```bash
alloy-host usb detach "J-Link" [vm-name]
alloy-host usb detach 1 [vm-name]
```

### `usb status`

Show all USB devices currently attached to any environment.

```bash
alloy-host usb status
```

---

## Summary table

| Command                           | What it does                   |
| --------------------------------- | ------------------------------ |
| `init <name> -b <blueprint>`      | Create a new environment       |
| `up [name]`                       | Start + provision              |
| `provision [name]`                | Re-apply blueprint updates     |
| `ssh [name]`                      | Open a shell                   |
| `stop [name]`                     | Halt the environment           |
| `destroy [name]`                  | Remove VM, keep data           |
| `destroy [name] --all`            | Remove VM and all data         |
| `list`                            | Show all environments          |
| `check-health`                    | Check Vagrant + VirtualBox     |
| `config show`                     | Show configuration             |
| `config set vagrant-path <p>`     | Set Vagrant path               |
| `config set vbox-manage-path <p>` | Set VBoxManage path            |
| `config unset vagrant-path`       | Unset Vagrant path override    |
| `config unset vbox-manage-path`   | Unset VBoxManage path override |
| `usb list [name]`                 | List USB devices               |
| `usb attach [device] [name]`      | Attach USB device              |
| `usb detach <device> [name]`      | Detach USB device              |
| `usb status`                      | Show all USB attachments       |
