#!/usr/bin/env bash
# install.sh — Bootstrap installer for alloy-host (Linux and macOS)
#
# Usage (always latest):
#   curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash
#
# Usage (pinned version — two equivalent forms):
#   curl -fsSL https://raw.githubusercontent.com/alloy-it/alloy-host-releases/main/scripts/install.sh | bash -s -- 0.3.0
#   ALLOY_HOST_VERSION=0.3.0 curl -fsSL .../install.sh | bash
#
# When running the script directly:
#   ./install.sh            # latest
#   ./install.sh 0.3.0      # pinned version
#
# Environment variables (all optional):
#   ALLOY_HOST_VERSION  Exact version, e.g. "0.3.0" (overridden by positional arg)
#   INSTALL_DIR         Where to install the binary (default: /usr/local/bin)
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
if [ $# -ge 1 ]; then
  VERSION="${1#v}"
elif [ -n "${ALLOY_HOST_VERSION:-}" ]; then
  VERSION="${ALLOY_HOST_VERSION#v}"
else
  VERSION=""
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
    die "Neither curl nor wget found. Please install one and retry."
  fi
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
if [ -n "$VERSION" ]; then
  VERSION="${VERSION#v}"
  TAG="v${VERSION}"
  TAR_FILENAME="${BINARY}_${VERSION}_${GOOS}_${ARCH}.tar.gz"
else
  TAG="latest"
  TAR_FILENAME="${BINARY}_latest_${GOOS}_${ARCH}.tar.gz"
fi

BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
printf "\n${BOLD}alloy-host installer${RESET}\n"
printf "  Binary : %s\n" "$BINARY"
printf "  Version: %s\n" "${VERSION:-latest}"
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

info "Extracting archive…"
tar -xzf "$TAR_FILE" -C "$TMPDIR_WORK"

EXTRACTED_BINARY="$TMPDIR_WORK/$BINARY"
[ -f "$EXTRACTED_BINARY" ] || die "Binary '${BINARY}' not found after extraction."

info "Installing to ${INSTALL_DIR} (requires sudo)…"
sudo install -m 0755 "$EXTRACTED_BINARY" "${INSTALL_DIR}/${BINARY}"

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
