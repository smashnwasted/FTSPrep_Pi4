#!/bin/bash
set -e

echo "======================================"
echo " FreeTAKServer PREP Script"
echo " Ubuntu 22.04 - Raspberry Pi Edition"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
   echo "Run with sudo:"
   echo "sudo $0"
   exit 1
fi

echo "[+] Updating system..."
apt update && apt upgrade -y

echo "[+] Installing base packages..."
apt install -y \
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

echo "[+] Installing Python build tools..."
python3 -m pip install --upgrade pip setuptools wheel

ARCH=$(dpkg --print-architecture)
echo "[+] Detected architecture: $ARCH"
if [[ "$ARCH" == "arm64" ]]; then
    echo "[+] Installing ARM math libs..."
    apt install -y libatlas-base-dev
fi

echo "[+] Opening firewall ports..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 19023/tcp
ufw allow 19023/udp
ufw allow 8087/tcp

echo "[+] Installing Node 18 (for Node-RED compatibility)..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "======================================"
echo " ✅ System ready for FreeTAKServer ZTI"
echo "--------------------------------------"
echo " Next step:"
echo "   cd ~"
echo "   wget https://raw.githubusercontent.com/FreeTAKTeam/FreeTAKServer/master/scripts/install/Install.sh"
echo "   sudo bash Install.sh"
echo "--------------------------------------"
echo " After installation:"
echo "   sudo systemctl status fts"
echo "   sudo journalctl -u fts -f"
echo "======================================"
