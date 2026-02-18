# alloy-host releases

Pre-built **alloy-host** binaries for Linux, macOS, and Windows.  
alloy-host is the host-side CLI for managing Alloy development environments (Vagrant/VirtualBox VMs or WSL2).

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

Check that both are available:

```bash
alloy-host check-health
```

If Vagrant or VirtualBox are installed in a custom location, set their paths:

```bash
alloy-host config set vagrant-path /path/to/vagrant
alloy-host config set vbox-manage-path /path/to/VBoxManage
```

---

## Installation

Download the archive for your OS and architecture, then extract the `alloy-host` binary (or `alloy-host.exe` on Windows) and put it in your `PATH`.

### Option A: Latest (recommended)

Use the **latest** release for stable “always current” URLs:

**Linux (amd64)**

```bash
wget https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_linux_amd64.tar.gz
tar -xzf alloy-host_latest_linux_amd64.tar.gz
sudo mv alloy-host /usr/local/bin/
```

**Linux (arm64)**

```bash
wget https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_linux_arm64.tar.gz
tar -xzf alloy-host_latest_linux_arm64.tar.gz
sudo mv alloy-host /usr/local/bin/
```

**macOS (Intel)**

```bash
curl -sSL -o alloy-host.tar.gz https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_darwin_amd64.tar.gz
tar -xzf alloy-host.tar.gz
sudo mv alloy-host /usr/local/bin/
```

**macOS (Apple Silicon)**

```bash
curl -sSL -o alloy-host.tar.gz https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_darwin_arm64.tar.gz
tar -xzf alloy-host.tar.gz
sudo mv alloy-host /usr/local/bin/
```

**Windows (PowerShell)**

Download the zip for your architecture from the [latest release](https://github.com/alloy-it/alloy-host-releases/releases/tag/latest), then extract and add the folder to your `PATH`, or run from that folder:

- amd64: `alloy-host_latest_windows_amd64.zip`
- arm64: `alloy-host_latest_windows_arm64.zip`

### Option B: Versioned

For a specific version, use the versioned release (e.g. `v0.1.0`). Replace `VERSION` with the tag (e.g. `0.1.0`):

```bash
# Example: Linux amd64, v0.1.0
wget https://github.com/alloy-it/alloy-host-releases/releases/download/v0.1.0/alloy-host_0.1.0_linux_amd64.tar.gz
tar -xzf alloy-host_0.1.0_linux_amd64.tar.gz
sudo mv alloy-host /usr/local/bin/
```

Pattern: `https://github.com/alloy-it/alloy-host-releases/releases/download/<tag>/alloy-host_<version>_<os>_<arch>.<ext>`

- **tag**: e.g. `v0.1.0` or `latest`
- **os**: `linux`, `darwin`, `windows`
- **arch**: `amd64`, `arm64`
- **ext**: `.tar.gz` (Linux/macOS) or `.zip` (Windows)

---

## Verify

```bash
alloy-host --version
alloy-host check-health
```

---

## Quick start

1. **Initialize** a dev VM (replace `my-vm` and blueprint name as needed):

   ```bash
   alloy-host init my-vm --blueprint nordic/nrf91
   ```

2. **Resolve** toolchain refs if your blueprint uses them (optional):

   ```bash
   cd my-vm
   alloy-host resolve
   ```

3. **Start** the VM:

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

| Command | Description |
|--------|-------------|
| `alloy-host init <name> --blueprint <blueprint>` | Create a new dev VM directory |
| `alloy-host up` | Start and provision the VM (run from VM dir) |
| `alloy-host provision` | Re-provision with current blueprints |
| `alloy-host ssh` | Open SSH session to the VM |
| `alloy-host stop` | Halt the VM |
| `alloy-host destroy` | Remove VM, keep config and data |
| `alloy-host list` | List registered VMs |
| `alloy-host resolve` | Resolve toolchain refs and write lockfile |
| `alloy-host validate` | Validate blueprint YAML |
| `alloy-host check-health` | Check Vagrant and VirtualBox |
| `alloy-host config show` | Show config (e.g. custom tool paths) |

---

## Checksums and SBOM

Versioned releases include `checksums.txt` and CycloneDX SBOMs (`.sbom.json`) in the release assets. Use them to verify integrity and audit dependencies.

---

This repo contains only release artifacts. For source and full documentation, see the **alloy-host** project.
