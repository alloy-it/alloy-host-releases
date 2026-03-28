# alloy-host releases

Pre-built **alloy-host** binaries for Linux, macOS, and Windows.  
alloy-host is the host-side CLI for managing Alloy development environments (Vagrant/VirtualBox VMs, WSL2, or Docker).

---

## Compatibility

| Platform   | Architectures | Archive format |
| ---------- | ------------- | -------------- |
| **Linux**  | `amd64`, `arm64` | `.tar.gz`   |
| **macOS**  | `amd64`, `arm64` | `.tar.gz`   |
| **Windows**| `amd64`, `arm64` | `.zip`      |

Static binaries (`CGO_ENABLED=0`). Versioned releases (e.g. `v0.3.0`) and a **`latest`** release with stable download URLs are published.

**Bootstrap installers** live in [`scripts/`](scripts/); maintainer-facing notes and copy-paste blocks are in [`scripts/README.md`](scripts/README.md).

---

## Prerequisites

Before using alloy-host you need:

- **Vagrant** — [Install](https://developer.hashicorp.com/vagrant/install)
- **VirtualBox** — [Install](https://www.virtualbox.org/wiki/Downloads)

**macOS (Homebrew):**

```bash
brew install --cask hashicorp-vagrant virtualbox
```

**Linux:**  
Download and install from the official sites: [Vagrant](https://developer.hashicorp.com/vagrant/install#linux), [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads).

**Windows:**  
Download and install from the official sites: [Vagrant](https://developer.hashicorp.com/vagrant/install#windows), [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

> **Docker / WSL2:** Other backends are supported; see the full docs. VirtualBox + Vagrant are the default.

Check that backend tools are available:

```bash
alloy-host check-health
```

If Vagrant or VirtualBox are installed in a custom location:

```bash
alloy-host config set vagrant-path /path/to/vagrant
alloy-host config set vbox-manage-path /path/to/VBoxManage
```

---

## Installation

### Bootstrap install (recommended)

**Linux and macOS** — requires `curl` or `wget`, `tar`, and `sudo` (default install dir is `/usr/local/bin`):

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash
```

**Pin a version:**

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash -s -- 0.3.0
```

**Windows** — download [`scripts/install.ps1`](https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.ps1), then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

By default the Windows script installs to `%LOCALAPPDATA%\alloy-host` and adds that folder to your **user** `PATH`. See [`scripts/README.md`](scripts/README.md) for `-InstallDir`, `-SkipPath`, and environment variables.

**macOS (Homebrew)** — alternative if you use the Alloy tap:

```bash
brew install alloy-it/tap/alloy-host
```

### Manual download (alternative)

Download the archive for your OS and architecture from the [**latest** release](https://github.com/alloy-it/alloy-host-releases/releases/tag/latest), extract `alloy-host` (or `alloy-host.exe` on Windows), and place it on your `PATH`.

Examples (stable `latest` URLs):

| OS | Command (conceptual) |
| -- | -------------------- |
| Linux amd64 | `alloy-host_latest_linux_amd64.tar.gz` |
| Linux arm64 | `alloy-host_latest_linux_arm64.tar.gz` |
| macOS Intel | `alloy-host_latest_darwin_amd64.tar.gz` |
| macOS Apple Silicon | `alloy-host_latest_darwin_arm64.tar.gz` |
| Windows | `alloy-host_latest_windows_amd64.zip` or `_arm64.zip` |

Full shell examples are in [`docs/installation.md`](docs/installation.md).

**Versioned** assets use the tag and numeric version in the filename, for example:

`https://github.com/alloy-it/alloy-host-releases/releases/download/v0.3.0/alloy-host_0.3.0_linux_amd64.tar.gz`

Pattern: `https://github.com/alloy-it/alloy-host-releases/releases/download/<tag>/alloy-host_<version>_<os>_<arch>.<ext>`

- **tag:** `latest` or `v0.3.0`
- **os:** `linux`, `darwin`, `windows`
- **arch:** `amd64`, `arm64`
- **ext:** `.tar.gz` (Linux/macOS) or `.zip` (Windows)

---

## Verify

```bash
alloy-host --version
alloy-host check-health
```

`check-health` confirms that `alloy-host` can find Vagrant and VirtualBox (for the default backend) and prints their versions.

---

## Quick start

1. **Initialize** a dev environment (replace `my-vm` and blueprint as needed):

   ```bash
   alloy-host init my-vm --blueprint nordic/nrf91
   ```

2. **Resolve** toolchain refs if your blueprint uses them (optional):

   ```bash
   cd my-vm
   alloy-host resolve
   ```

3. **Start** the environment:

   ```bash
   alloy-host up
   ```

4. **SSH** into the VM:

   ```bash
   alloy-host ssh
   ```

5. **Re-provision** after changing blueprint files:

   ```bash
   alloy-host provision
   ```

6. **Destroy** the VM (keeps config and data so you can run `up` again):

   ```bash
   alloy-host destroy
   ```

---

## Commands overview

| Command                                          | Description                                  |
| ------------------------------------------------ | -------------------------------------------- |
| `alloy-host init <name> --blueprint <blueprint>` | Create a new dev environment directory       |
| `alloy-host up`                                  | Start and provision (run from env directory) |
| `alloy-host provision`                           | Re-provision with current blueprints         |
| `alloy-host ssh`                                 | Open a shell inside the environment          |
| `alloy-host stop`                                | Halt the environment                         |
| `alloy-host destroy`                             | Remove VM; keep config and data              |
| `alloy-host list`                                | List registered environments                 |
| `alloy-host resolve`                             | Resolve toolchain refs and write lockfile    |
| `alloy-host validate`                            | Validate blueprint YAML                      |
| `alloy-host check-health`                        | Check Vagrant and VirtualBox                 |
| `alloy-host config show`                         | Show config (e.g. custom tool paths)         |

---

## Checksums and SBOM

Versioned releases include `checksums.txt` and CycloneDX SBOMs (`.sbom.json`) in the release assets. Use them to verify integrity and audit dependencies.

---

This repository contains release artifacts and installer scripts. For source and extended documentation, see the **alloy-host** project and [`docs/`](docs/).
