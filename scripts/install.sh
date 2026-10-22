#!/usr/bin/env bash
# install.sh — Bootstrap installer for alloy-host (Linux and macOS)
#
# Usage (always latest):
#   curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash
#
# Usage (pinned version — two equivalent forms):
#   curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash -s -- 0.3.0
#   curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | ALLOY_HOST_VERSION=0.3.0 bash
#
# When running the script directly:
#   ./install.sh            # latest
#   ./install.sh 0.3.0      # pinned version
#
# Environment variables (all optional):
#   ALLOY_HOST_VERSION  Exact version, e.g. "0.3.0" (overridden by positional arg)
#   INSTALL_DIR         Where to install the binary (default: /usr/local/bin)
#   ALLOY_REQUIRE_CHECKSUM  Set to "1" to abort when checksums.txt is missing
#   ALLOY_CHECKSUM_OVERRIDE Test hook: force checksum verification to fail
#   NO_COLOR            Set to any value to disable coloured output
#
# Windows: use scripts/install.ps1 instead.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO="alloy-it/alloy-host-releases"
BINARY="alloy-host"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Positional argument takes precedence over the environment variable.
VERSION_SOURCE=""
if [ $# -ge 1 ]; then
  VERSION="${1#v}"
  VERSION_SOURCE="positional argument"
elif [ -n "${ALLOY_HOST_VERSION:-}" ]; then
  VERSION="${ALLOY_HOST_VERSION#v}"
  VERSION_SOURCE="ALLOY_HOST_VERSION environment variable"
else
  VERSION=""
  VERSION_SOURCE="latest GitHub release"
fi

# ---------------------------------------------------------------------------
# Colours (disabled when not a terminal or NO_COLOR is set)
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD='\033[1m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  RESET='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' RED='' CYAN='' RESET=''
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { printf "${CYAN}==>${RESET} %s\n" "$*"; }
success() { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}warn:${RESET} %s\n" "$*" >&2; }
die()     { printf "${RED}error:${RESET} %s\n" "$*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1 — please install it and retry."
}

download() {
  local url="$1" dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -sSfL --retry 3 --retry-delay 2 -o "$dest" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --tries=3 --waitretry=2 -O "$dest" "$url"
  else
    die "Neither curl nor wget found — install one (e.g. apt-get install -y curl) and retry."
  fi
}

download_optional() {
  local url="$1" dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -sSfL --retry 3 --retry-delay 2 -o "$dest" "$url" 2>/dev/null
  elif command -v wget >/dev/null 2>&1; then
    wget -q --tries=3 --waitretry=2 -O "$dest" "$url" 2>/dev/null
  else
    return 1
  fi
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "Cannot write to ${INSTALL_DIR} — run as root, install sudo, or set INSTALL_DIR to a writable directory."
  fi
}

resolve_newest_semver_version() {
  local api_url="https://api.github.com/repos/${REPO}/releases?per_page=30"
  local releases_json
  releases_json="$(mktemp)"
  if command -v curl >/dev/null 2>&1; then
    if ! curl -sSfL --retry 3 --retry-delay 2 -o "$releases_json" "$api_url"; then
      rm -f "$releases_json"
      return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -q --tries=3 --waitretry=2 -O "$releases_json" "$api_url"; then
      rm -f "$releases_json"
      return 1
    fi
  else
    rm -f "$releases_json"
    return 1
  fi
  # Plain X.Y.Z tags from non-draft, non-prerelease releases only (no python/jq).
  local ver
  ver="$(awk '
    function flush() {
      if (tag == "") return
      if (pre != 0 || dr != 0) { tag = ""; return }
      if (tag ~ /^v[0-9]+\.[0-9]+\.[0-9]+$/ || tag ~ /^[0-9]+\.[0-9]+\.[0-9]+$/) {
        sub(/^v/, "", tag)
        print tag
      }
      tag = ""
    }
    BEGIN { tag = ""; pre = 1; dr = 1 }
    /^[[:space:]]*\{/ { flush(); pre = 1; dr = 1 }
    /"tag_name"/ {
      line = $0
      sub(/.*"tag_name"[[:space:]]*:[[:space:]]*"/, "", line)
      sub(/".*/, "", line)
      tag = line
    }
    /"prerelease"/ {
      if ($0 ~ /"prerelease"[[:space:]]*:[[:space:]]*false/) pre = 0
      else pre = 1
    }
    /"draft"/ {
      if ($0 ~ /"draft"[[:space:]]*:[[:space:]]*false/) dr = 0
      else dr = 1
    }
    END { flush() }
  ' "$releases_json" | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)"
  rm -f "$releases_json"
  [ -n "$ver" ] || return 1
  printf '%s\n' "$ver"
}

verify_artifact_checksum() {
  local artifact_path="$1"
  local artifact_name="$2"
  local checksums_path="$TMPDIR_WORK/checksums.txt"

  if [ -n "${ALLOY_CHECKSUM_OVERRIDE:-}" ]; then
    local actual
    if command -v sha256sum >/dev/null 2>&1; then
      actual="$(sha256sum "$artifact_path" | awk '{print $1}')"
    elif command -v shasum >/dev/null 2>&1; then
      actual="$(shasum -a 256 "$artifact_path" | awk '{print $1}')"
    else
      die "Neither sha256sum nor shasum found — cannot verify checksum."
    fi
    if [ "$actual" != "$ALLOY_CHECKSUM_OVERRIDE" ]; then
      rm -f "$artifact_path"
      die "Checksum verification failed for ${artifact_name}."
    fi
    success "Checksum verified for ${artifact_name}"
    return 0
  fi

  if ! download_optional "${BASE_URL}/checksums.txt" "$checksums_path"; then
    if [ "${ALLOY_REQUIRE_CHECKSUM:-}" = "1" ]; then
      rm -f "$artifact_path"
      die "checksums.txt not found at ${BASE_URL}/checksums.txt (ALLOY_REQUIRE_CHECKSUM=1)."
    fi
    warn "checksums.txt not found for this release — skipping verification."
    return 0
  fi

  if ! grep -qF "$artifact_name" "$checksums_path"; then
    rm -f "$artifact_path"
    die "checksums.txt has no entry for ${artifact_name}."
  fi

  local verify_dir checksum_line checksum_only
  verify_dir="$(dirname "$artifact_path")"
  checksum_line="$(grep -F "$artifact_name" "$checksums_path" | head -1)"
  checksum_only="$TMPDIR_WORK/checksum-verify.txt"
  printf '%s\n' "$checksum_line" > "$checksum_only"

  if command -v sha256sum >/dev/null 2>&1; then
    if ! (cd "$verify_dir" && sha256sum -c "$checksum_only"); then
      rm -f "$artifact_path"
      die "Checksum verification failed for ${artifact_name}."
    fi
  elif command -v shasum >/dev/null 2>&1; then
    if ! (cd "$verify_dir" && shasum -a 256 -c "$checksum_only"); then
      rm -f "$artifact_path"
      die "Checksum verification failed for ${artifact_name}."
    fi
  else
    die "Neither sha256sum nor shasum found — cannot verify checksum."
  fi
  success "Checksum verified for ${artifact_name}"
}

# ---------------------------------------------------------------------------
# Platform checks
# ---------------------------------------------------------------------------
OS_RAW="$(uname -s)"
ARCH_RAW="$(uname -m)"

case "$OS_RAW" in
  Linux)  GOOS="linux" ;;
  Darwin) GOOS="darwin" ;;
  *)
    die "This script supports Linux and macOS only (detected: $OS_RAW). On Windows, use scripts/install.ps1 from ${REPO}."
    ;;
esac

case "$ARCH_RAW" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  arm64)   ARCH="arm64" ;;
  *)       die "Unsupported architecture: $ARCH_RAW (only amd64 and arm64 are supported)." ;;
esac

# ---------------------------------------------------------------------------
# Resolve tag and archive name (matches GoReleaser + release workflow)
# ---------------------------------------------------------------------------
USE_FLOATING_LATEST="0"
if [ -z "$VERSION" ]; then
  if resolved="$(resolve_newest_semver_version 2>/dev/null)" && [ -n "$resolved" ]; then
    VERSION="$resolved"
    VERSION_SOURCE="newest release"
  else
    warn "Could not resolve the newest semver release from GitHub — falling back to floating 'latest' (checksum cannot be verified)."
    USE_FLOATING_LATEST="1"
    VERSION_SOURCE="floating latest (checksum not verified)"
  fi
fi

if [ -n "$VERSION" ]; then
  VERSION="${VERSION#v}"
  TAG="v${VERSION}"
  TAR_FILENAME="${BINARY}_${VERSION}_${GOOS}_${ARCH}.tar.gz"
elif [ "$USE_FLOATING_LATEST" = "1" ]; then
  TAG="latest"
  TAR_FILENAME="${BINARY}_latest_${GOOS}_${ARCH}.tar.gz"
fi

BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
printf "\n${BOLD}alloy-host installer${RESET}\n"
printf "  Binary : %s\n" "$BINARY"
if [ "$VERSION_SOURCE" = "newest release" ]; then
  printf "  Version: %s (newest release)\n" "$VERSION"
elif [ -n "$VERSION" ]; then
  printf "  Version: %s (from %s)\n" "$VERSION" "$VERSION_SOURCE"
else
  printf "  Version: latest (from %s)\n" "$VERSION_SOURCE"
fi
printf "  OS/Arch: %s/%s\n" "$GOOS" "$ARCH"
printf "  Install: %s\n\n" "$INSTALL_DIR"

need_cmd uname
need_cmd tar

TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT

info "Downloading ${TAR_FILENAME}…"
TAR_FILE="$TMPDIR_WORK/$TAR_FILENAME"
if ! download "${BASE_URL}/${TAR_FILENAME}" "$TAR_FILE"; then
  die "Failed to download ${BASE_URL}/${TAR_FILENAME}"
fi

verify_artifact_checksum "$TAR_FILE" "$TAR_FILENAME"

info "Extracting archive…"
tar -xzf "$TAR_FILE" -C "$TMPDIR_WORK"

EXTRACTED_BINARY="$TMPDIR_WORK/$BINARY"
[ -f "$EXTRACTED_BINARY" ] || die "Binary '${BINARY}' not found after extraction."

if [ -w "$INSTALL_DIR" ] 2>/dev/null; then
  info "Installing to ${INSTALL_DIR}…"
  install -m 0755 "$EXTRACTED_BINARY" "${INSTALL_DIR}/${BINARY}"
else
  info "Installing to ${INSTALL_DIR} (requires elevated privileges)…"
  run_as_root install -m 0755 "$EXTRACTED_BINARY" "${INSTALL_DIR}/${BINARY}"
fi

INSTALLED_PATH="$(command -v "$BINARY" 2>/dev/null || true)"
if [ -z "$INSTALLED_PATH" ]; then
  warn "${BINARY} not found in PATH after install."
  warn "Make sure ${INSTALL_DIR} is in your PATH, e.g. add to ~/.zshrc:"
  warn "  export PATH=\"\$PATH:${INSTALL_DIR}\""
else
  INSTALLED_VERSION="$("$INSTALLED_PATH" --version 2>&1 || true)"
  printf "\n${BOLD}${GREEN}Installation complete!${RESET}\n"
  success "Binary : ${INSTALLED_PATH}"
  success "Version: ${INSTALLED_VERSION}"
fi

printf "\n${CYAN}Get started:${RESET}\n"
printf "  alloy-host check-health\n\n"
