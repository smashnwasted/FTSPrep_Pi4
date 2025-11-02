#!/bin/bash
set -e

echo "======================================"
echo " FreeTAKServer PREP Script"
echo " Ubuntu 22.04 - Raspberry Pi Edition"
echo " curl/run ready version"
echo "======================================"

# Must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "[!] This script must be run with sudo or as root:"
   echo "    curl -sSL <script_url> | sudo bash"
   exit 1
fi

echo "[+] Updating system..."
apt update -y
apt upgrade -y

echo "[+] Installing base packages..."
DEBIAN_FRONTEND=noninteractive apt install -y \
    git curl wget unzip build-essential software-properties-common \
    python3 python3-pip python3-venv python3-dev \
    libffi-dev libssl-dev \
    redis-server postgresql postgresql-contrib \
    libxml2-dev libxslt1-dev zlib1g-dev \
    libjpeg-dev libfreetype6-dev \
    net-tools ufw

echo "[+] Enabling Redis & PostgreSQL..."
systemctl enable --now redis-server
systemctl enable --now postgresql

echo "[+] Upgrading Python build tools..."
python3 -m pip install --upgrade pip setuptools wheel

ARCH=$(dpkg --print-architecture)
echo "[+] Detected architecture: $ARCH"
if [[ "$ARCH" == "arm64" ]]; then
    echo "[+] Installing ARM math libs..."
    apt install -y libatlas-base-dev
fi

ec
