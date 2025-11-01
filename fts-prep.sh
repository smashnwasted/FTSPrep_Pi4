#!/bin/bash
set -e

echo "======================================"
echo " FreeTAKServer Dependency Installer"
echo " Ubuntu 22.04 - Raspberry Pi Edition"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
   echo "Run this script with sudo:"
   echo "sudo $0"
   exit 1
fi

echo "Updating system packages..."
apt update && apt upgrade -y

echo "Installing required packages..."
apt install -y \
    git curl wget unzip software-properties-common \
    build-essential pkg-config \
    python3 python3-pip python3-venv python3-dev \
    libffi-dev libssl-dev libpq-dev \
    libxml2-dev libxslt1-dev zlib1g-dev \
    libjpeg-dev libfreetype6-dev libblas-dev liblapack-dev \
    net-tools ufw \
    redis-server \
    postgresql postgresql-contrib

echo "Enabling services..."
systemctl enable redis-server --now
systemctl enable postgresql --now

echo "Upgrading pip..."
python3 -m pip install --upgrade pip setuptools wheel

ARCH=$(dpkg --print-architecture)
echo "Architecture detected: $ARCH"
if [[ "$ARCH" == "arm64" ]]; then
    echo "Installing ARM optimizations..."
    apt install -y libatlas-base-dev
fi

echo "Installing python packages..."
python3 -m pip install --upgrade \
    psycopg2-binary redis flask requests \
    gevent eventlet \
    grpcio grpcio-tools \
    protobuf==3.20.* pillow

echo "Opening firewall ports..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 19023/tcp
ufw allow 19023/udp
ufw allow 8087/tcp

echo "======================================"
echo "✅ Dependencies installed!"
echo "➡️ Now run the FTS Zero Touch Installer"
echo "======================================"
