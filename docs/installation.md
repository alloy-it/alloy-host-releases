# Installation

`alloy-host` is a single binary. Install it once on your machine and you're ready.

---

## Step 1 — Install the required tools

`alloy-host` manages virtual machines, so it needs a virtualisation stack on your machine.

### macOS

Install Vagrant and VirtualBox with Homebrew:

```bash
brew install --cask hashicorp-vagrant virtualbox
```

> **Apple Silicon (M1/M2/M3):** VirtualBox has experimental support for ARM Macs. If you run into issues, see the [Troubleshooting](troubleshooting.md) guide.

### Windows

Download and run the installers:

- **Vagrant:** [developer.hashicorp.com/vagrant/install](https://developer.hashicorp.com/vagrant/install#windows)
- **VirtualBox:** [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)

Both installers add their tools to `PATH` automatically.

> **Windows alternative — WSL2:** If you prefer WSL2 over VirtualBox, you only need WSL2 enabled (`wsl --install` in an elevated PowerShell). See [Your First Environment](your-first-environment.md#windows-wsl2-backend) for details.

### Linux

**Vagrant:**

```bash
# Debian / Ubuntu
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor \
  -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vagrant
```

**VirtualBox:** Download the `.deb` or `.rpm` for your distribution from [virtualbox.org/wiki/Linux_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads) and install it.

> **Linux USB passthrough:** Add your user to the `vboxusers` group so VirtualBox can access USB devices:
>
> ```bash
> sudo usermod -aG vboxusers $USER
> # Log out and back in for the change to take effect
> ```

---

## Step 2 — Install alloy-host

Download the archive for your OS and architecture, extract the binary, and put it somewhere in your `PATH`.

### macOS — Apple Silicon (M1/M2/M3)

```bash
curl -sSL -o alloy-host.tar.gz \
  https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_darwin_arm64.tar.gz
tar -xzf alloy-host.tar.gz
sudo mv alloy-host /usr/local/bin/
```

### macOS — Intel

```bash
curl -sSL -o alloy-host.tar.gz \
  https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_darwin_amd64.tar.gz
tar -xzf alloy-host.tar.gz
sudo mv alloy-host /usr/local/bin/
```

### Windows — PowerShell

```powershell
# Intel / AMD (most PCs)
Invoke-WebRequest -Uri https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_windows_amd64.zip `
  -OutFile alloy-host.zip
Expand-Archive alloy-host.zip -DestinationPath "$env:LOCALAPPDATA\alloy-host"

# Add to PATH for this session (run once to make it permanent, add to your profile)
$env:PATH += ";$env:LOCALAPPDATA\alloy-host"
```

> For a permanent install, add `%LOCALAPPDATA%\alloy-host` to your user `PATH` via **System Properties → Environment Variables**.

### Linux — amd64 (Intel/AMD)

```bash
wget https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_linux_amd64.tar.gz
tar -xzf alloy-host_latest_linux_amd64.tar.gz
sudo mv alloy-host /usr/local/bin/
```

### Linux — arm64

```bash
wget https://github.com/alloy-it/alloy-host-releases/releases/download/latest/alloy-host_latest_linux_arm64.tar.gz
tar -xzf alloy-host_latest_linux_arm64.tar.gz
sudo mv alloy-host /usr/local/bin/
```

---

## Step 3 — Verify the installation

```bash
alloy-host --version
alloy-host check-health
```

`check-health` confirms that `alloy-host` can find Vagrant and VirtualBox and reports their versions. You should see something like:

```bash
✓ vagrant   found at /usr/bin/vagrant (2.4.1)
✓ vboxmanage found at /usr/bin/VBoxManage (7.0.18)
```

If either tool is flagged as missing, check that its installer finished successfully and that it is in your `PATH`.

---

## Installing a specific version

The `latest` release always points to the most recent stable build. If you need a specific version, replace `latest` in the URL and filename with the version number:

```bash
# Example: v0.2.0 on Linux amd64
wget https://github.com/alloy-it/alloy-host-releases/releases/download/v0.2.0/alloy-host_0.2.0_linux_amd64.tar.gz
```

URL pattern:

```TOML
https://github.com/alloy-it/alloy-host-releases/releases/download/<tag>/alloy-host_<version>_<os>_<arch>.<ext>
```

| Placeholder | Values                                      |
| ----------- | ------------------------------------------- |
| `<tag>`     | `latest` or `v0.2.0`                        |
| `<os>`      | `darwin`, `linux`, `windows`                |
| `<arch>`    | `amd64`, `arm64`                            |
| `<ext>`     | `.tar.gz` (macOS/Linux) or `.zip` (Windows) |

---

## Custom tool locations

If Vagrant or VirtualBox are installed in a non-standard location, tell `alloy-host` where to find them:

```bash
alloy-host config set vagrant-path /opt/vagrant/bin/vagrant
alloy-host config set vbox-manage-path /opt/VirtualBox/VBoxManage
```

To go back to automatic detection:

```bash
alloy-host config unset vagrant-path
alloy-host config unset vbox-manage-path
```

---

## Next step

→ [Your First Environment](your-first-environment.md)
