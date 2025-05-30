#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

VERSION=${VERSION:-"latest"}
INSTALL_DIR="/usr/local/lib/novops"
REQUIRED_PACKAGES=(ca-certificates curl xz-utils tar build-essential)
BIN_NAME="novops"

function detect_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)
      echo "x86_64"
      ;;
    aarch64|arm64)
      echo "aarch64"
      ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      exit 1
      ;;
  esac
}

function detect_os() {
  local os
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$os" in
    linux)
      echo "linux"
      ;;
    darwin)
      echo "macos"
      ;;
    *)
      echo "Unsupported OS: $os" >&2
      exit 1
      ;;
  esac
}

function install_required_packages() {
  local missing=()
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [ ${#missing[@]} -ne 0 ]; then
    echo "Installing: ${missing[*]}"
    apt-get update -y
    apt-get install -y --no-install-recommends "${missing[@]}"
    rm -rf /var/lib/apt/lists/*
  fi
}

function prepare_install_dir() {
  mkdir -p "$INSTALL_DIR"
}

function install_binary_release() {
  local arch=$(detect_arch)
  local os=$(detect_os)
  local archive="novops_${os}_${arch}.zip"
  local url="https://github.com/PierreBeucher/novops/releases/${VERSION}/download/${archive}"
  
  echo "Downloading $archive from $url"
  if curl -sL -o "/tmp/$archive" "$url"; then
    echo "Extracting into $INSTALL_DIR"
    unzip -q "/tmp/$archive" -d "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR/$BIN_NAME"
    ln -sf "$INSTALL_DIR/$BIN_NAME" "/usr/local/bin/$BIN_NAME"
    rm "/tmp/$archive"
    return 0
  else
    return 1
  fi
}

main() {
  echo "→ Installing Novops..."
  if [ "$(detect_os)" = "linux" ]; then
    install_required_packages
  fi
  prepare_install_dir

  if install_binary_release; then
    echo "✔ Binary release installed."
  fi

  echo "✔ Novops is now available: $(novops --version)"
}

main
