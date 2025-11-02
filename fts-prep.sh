#!/bin/bash
set -e

echo "======================================"
echo " FreeTAKServer FULL RESET + PREP"
echo " Ubuntu 22.04 - Raspberry Pi Edition"
echo " curl/run ready version"
echo "======================================"

# Must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "[!] This script must be run with sudo or as root:"
   echo "    curl -sSL <script_url> | sudo bash"
   exit 1
fi

echo "[+] Stopping old FTS service if it exists..."
systemctl stop fts || true
systemctl disable fts || true
rm -f /etc/systemd/system/fts.service || true
systemctl daemon-reload || true

echo "[+] Removing old FTS files..."
rm -rf /root/fts.venv
rm -rf /opt/fts
rm -rf /home/fts
rm -rf /var/log/fts

echo "[+] Uninstalling old Python packages..."
pip3 uninstall -y FreeTAKServer FreeTAKHub FreeTAKServer-UI digitalpy || true

echo "[+] Resetting firewall..."
ufw reset || true
ufw default deny incoming
ufw default allow outgoing
ufw enable

echo "[+] Removing old Node.js / Node-RED..."
apt remove -y nodejs npm || true
apt autoremove -y || true

echo "[+] Updating system packages..."
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

echo "[+] Installing Python build tools..."
python3 -m pip install --upgrade pip setuptools wheel

echo "[+] Installing Python 3.10 if not present..."
apt install -y python3.10 python3.10-venv python3.10-dev || true
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
update-alternatives --config python3 || true

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
echo " ✅ Raspberry Pi fully reset & prepared!"
echo "--------------------------------------"
echo "Next steps:"
echo "  1) Download & run the official FreeTAKServer ZTI:"
echo "       cd ~"
echo "       wget https://raw.githubusercontent.com/FreeTAKTeam/FreeTAKServer/master/scripts/install/Install.sh"
echo "       sudo bash Install.sh"
echo "  2) Check service & logs after ZTI completes:"
echo "       sudo systemctl status fts"
echo "       sudo journalctl -u fts -f"
echo "  3) Connect ATAK clients using ZeroTier IP"
echo "======================================"
