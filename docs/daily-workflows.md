# Daily Workflows

Common day-to-day tasks you'll do with `alloy-host`.

---

## Starting and stopping

### Start your environment

```bash
alloy-host up my-nrf91
```

If the VM was stopped, this resumes it in seconds. It does not re-provision — your tools are already installed.

### Open a shell

```bash
alloy-host ssh my-nrf91
```

### Stop for the day

```bash
alloy-host stop my-nrf91
```

Halts the VM gracefully. Your work inside the VM (code, build artifacts, settings) is saved on the persistent disk.

### Typical daily pattern

```bash
# Morning
alloy-host up my-nrf91
alloy-host ssh my-nrf91

# ... work inside the VM ...

# Evening
exit                       # exit the SSH session
alloy-host stop my-nrf91
```

---

## Working with multiple environments

You can have as many environments as you like — one per project, per board, or per customer.

```bash
# Create two environments for different boards
alloy-host init project-nrf91 --blueprint nordic/nrf91
alloy-host init project-owa4x --blueprint owasys/owa4x

# See all your environments
alloy-host list

# Start and use them independently
alloy-host up project-nrf91
alloy-host ssh project-nrf91

alloy-host up project-owa4x
alloy-host ssh project-owa4x
```

Each environment is completely isolated — different tools, different home directories, no conflicts.

`alloy-host list` shows all your registered environments with their status:

```TOML
NAME             BLUEPRINT        BACKEND   STATUS
project-nrf91    nordic/nrf91     vm        running
project-owa4x    owasys/owa4x     vm        stopped
```

---

## Destroying and recreating

Sometimes you want a clean slate — a fresh VM with everything reinstalled from scratch.

### Destroy, keeping your work

```bash
alloy-host destroy my-nrf91
```

This removes the VM entirely, but your persistent data disk (`home-data.vdi`) is kept. When you run `up` again, a fresh VM is created and your files in `/home/vagrant` are exactly where you left them.

```bash
alloy-host up my-nrf91     # fresh VM, same data
alloy-host ssh my-nrf91    # your files are still there
```

Use this when:

- The VM is broken or corrupted
- You want a clean OS + tools install
- You're switching to a newer blueprint version

### Destroy everything

```bash
alloy-host destroy my-nrf91 --all
```

This removes the VM **and** the persistent data disk. Use this only when you want to completely clean up an environment and no longer need the data inside it.

---

## Getting a blueprint update

When the Alloy team publishes an updated version of a blueprint (new toolchain, bug fix, added package), re-provisioning applies the update without destroying your work.

### Re-provision an existing environment

```bash
alloy-host provision my-nrf91
```

This runs `alloy-provisioner` again inside the running VM. The provisioner fetches the latest blueprint and applies any changes idempotently — tools that are already installed and up to date are skipped; only what changed is applied.

If you want a completely clean install of the new blueprint:

```bash
alloy-host destroy my-nrf91    # remove VM, keep data
alloy-host up my-nrf91         # fresh VM with latest blueprint
```

---

## Listing and finding environments

```bash
alloy-host list
```

Shows every environment you've created with its blueprint, backend, status, and location on disk.

---

## Keeping environments across machine rebuilds

The persistent data disk (`home-data.vdi`) lives inside your environment directory. To back up or migrate an environment:

1. Stop the VM: `alloy-host stop my-nrf91`
2. Copy the `my-nrf91/` directory (including `home-data.vdi`) to your backup or new machine.
3. On the new machine, run `alloy-host up my-nrf91` from the parent directory — `alloy-host` re-registers the environment automatically.

---

## Environment credentials

Each environment directory contains a `.alloy-env` file with optional credentials:

```bash
# my-nrf91/.alloy-env
ALLOY_REGISTRY_USER=""
ALLOY_REGISTRY_TOKEN=""
ALLOY_GITHUB_PAT=""
```

If your blueprint pulls from private repositories or registries, fill in the relevant tokens here before running `alloy-host up`. This file is never committed to Git.
