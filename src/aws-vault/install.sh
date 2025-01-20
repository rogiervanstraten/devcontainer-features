#!/usr/bin/env bash

VERSION=${VERSION:-"latest"}
INSTALL_DIR="/usr/local/lib/aws-vault"
REQUIRED_PACKAGES=(ca-certificates curl)
ARCHITECTURE="linux-amd64"
BIN_NAME="aws-vault"

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
    mkdir -p "$INSTALL_DIR"
}

function download_and_install_aws_vault() {
    local binary_name="aws-vault-$ARCHITECTURE"
    local download_url="https://github.com/99designs/aws-vault/releases/$VERSION/download/$binary_name"

    echo "Downloading aws-vault from $download_url"
    curl -L -o "$INSTALL_DIR/$BIN_NAME" "$download_url"

    echo "Setting permissions..."
    chmod 755 "$INSTALL_DIR/$BIN_NAME"
    ln -sf "$INSTALL_DIR/$BIN_NAME" "/usr/local/bin/$BIN_NAME"
}

function main() {
    echo "Starting aws-vault installation..."
    
    check_root_access
    clean_system
    install_required_packages
    prepare_installation_directory
    download_and_install_aws_vault
    clean_system
    
    echo "aws-vault has been successfully installed!"
}

main