#!/usr/bin/env bash

VERSION=${VERSION:-$(zig version 2>/dev/null)}
ZLS_VERSION="${VERSION:-"0.13.0"}"
INSTALL_DIR="/usr/local/lib/zls"
REQUIRED_PACKAGES=(ca-certificates wget jq xz-utils)
ARCHITECTURE=$(uname -m)

set -e

function check_root_access() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run as root."
        echo "Please use: sudo, su, or add 'USER root' to your Dockerfile."
        exit 1
    fi
}

function clean_system() {
    echo "Cleaning package lists..."
    rm -rf /var/lib/apt/lists/*
}

function install_required_packages() {
    local missing_packages=()
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -s "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "Installing missing packages: ${missing_packages[*]}"
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Updating package lists..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "${missing_packages[@]}"
    fi
}

function prepare_installation_directory() {
    echo "Preparing installation directory..."
    rm -rf "$INSTALL_DIR"  # Remove existing installation
    mkdir -p "$INSTALL_DIR"
}

function download_and_install_zls() {
    local tarball="zls-$ARCHITECTURE-linux.tar.xz"
    local download_url="https://github.com/zigtools/zls/releases/download/$ZLS_VERSION/$tarball"

    echo "Downloading ZLS $download_url"
    wget "$download_url"

    echo "Extracting ZLS..."
    tar -xvf "$tarball" -C "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR/zls"
    ln -sf "$INSTALL_DIR/zls" "/usr/local/bin/zls"
    rm -f "$tarball"
}

function main() {
    echo "Starting ZLS installation..."
    
    check_root_access
    clean_system
    install_required_packages
    prepare_installation_directory
    download_and_install_zls
    clean_system
    
    echo "ZLS $ZLS_VERSION has been successfully installed!"
}

main
