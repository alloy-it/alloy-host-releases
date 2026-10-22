# alloy-host bootstrap installers

`install.sh` (Linux and macOS) and `install.ps1` (Windows) are one-command bootstrap scripts. They detect your platform, download the matching release asset from [alloy-host-releases](https://github.com/alloy-it/alloy-host-releases), and install the binary.

---

## Where to host the scripts (optional)

### Option A — Serve from the website (recommended for short URLs)

Copy `install.sh` to your static site under a **distinct name** so it does not collide with the provisioner installer (e.g. `install-alloy-host.sh` at the web root, or under `/docs/`).

Serve with **`Content-Type: text/plain`** so clients receive plain text.

Example stable URL (after you publish the file):

```
https://alloy-it.io/install-alloy-host.sh
```

### Option B — Raw GitHub URL (works immediately)

**Linux / macOS:**

```
https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh
```

**Windows** — download the script and run it locally (do not pipe to `Invoke-Expression` unless you accept the same trust model as `curl | bash`):

```
https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.ps1
```

---

## What to post in documentation

### Linux / macOS — latest

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash
```

### Linux / macOS — pinned version

Positional argument:

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash -s -- 2.1.0
```

Environment variable (accepts `2.1.0` or `v2.1.0`). Put the variable **before** `bash`, not before `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | ALLOY_HOST_VERSION=2.1.0 bash
```

The form `ALLOY_HOST_VERSION=2.1.0 curl … | bash` sets the variable only for `curl` and does **not** pin the version.

The script verifies `checksums.txt` from the release. Set `ALLOY_REQUIRE_CHECKSUM=1` to treat a missing checksum file as fatal.

Direct execution:

```bash
./install.sh            # latest
./install.sh 0.3.0      # pinned
./install.sh v0.3.0     # leading v is accepted
```

### Windows — latest

Save `install.ps1`, then:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Windows — pinned version

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Version 0.3.0
```

Or set `ALLOY_HOST_VERSION` before running the script.

---

## Complete copy-paste block (Markdown)

````markdown
## Install alloy-host

**Linux / macOS** — bootstrap script (requires `curl` or `wget`, `tar`, and `sudo` for `/usr/local/bin`):

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash
```

**Windows** — download [install.ps1](https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.ps1), then:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**Pin a version (Unix):**

```bash
curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash -s -- 2.1.0
```

**Verify:**

```bash
alloy-host --version
alloy-host check-health
```

Manual downloads: [GitHub Releases](https://github.com/alloy-it/alloy-host-releases/releases).
````

---

## How the scripts work (summary)

| Step | `install.sh` (Linux / macOS) | `install.ps1` (Windows) |
|------|------------------------------|-------------------------|
| 1 | Detects OS (`linux` / `darwin`) and arch (`amd64` / `arm64`) | Detects arch from `PROCESSOR_ARCHITECTURE` |
| 2 | Downloads `tar.gz` from `releases/download/<tag>/` | Downloads `zip` from the same layout |
| 3 | Extracts to a temp directory | Expands archive to a temp directory |
| 4 | `sudo install` to `/usr/local/bin` (override with `INSTALL_DIR`) | Copies `alloy-host.exe` to `%LOCALAPPDATA%\alloy-host` by default |
| 5 | Prints `--version` when the binary is on `PATH` | Appends install dir to **user** `PATH` unless `-SkipPath` |

---

## Environment variables / parameters (advanced)

| Name | Applies to | Default | Purpose |
|------|------------|---------|---------|
| `ALLOY_HOST_VERSION` | sh, ps1 | *(latest)* | Exact version, e.g. `2.1.0` (sh: overridden by positional arg) |
| `ALLOY_REQUIRE_CHECKSUM` | sh only | unset | Set to `1` to abort when `checksums.txt` is missing |
| `INSTALL_DIR` | sh only | `/usr/local/bin` | Install directory for `alloy-host` |
| `NO_COLOR` | sh only | unset | Disable coloured output |
| `-InstallDir` | ps1 only | `%LOCALAPPDATA%\alloy-host` | Install directory for `alloy-host.exe` |
| `-SkipPath` | ps1 only | off | Do not modify user `PATH` |
