#!/bin/bash
# Install project dependencies (Ubuntu)
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run as root: sudo ./install.sh"
    exit 1
fi

echo "[1/6] Updating packages..."
apt-get update -qq

echo "[2/6] Installing base deps..."
apt-get install -y -qq \
    curl wget git software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release

echo "[3/6] Installing LXD..."
if ! command -v lxd &> /dev/null; then
    snap install lxd
else
    echo "  already installed"
fi

echo "[4/6] Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update -qq && apt-get install -y -qq terraform
else
    echo "  already installed"
fi

echo "[5/6] Installing Ansible..."
if ! command -v ansible &> /dev/null; then
    add-apt-repository -y ppa:ansible/ansible
    apt-get update -qq && apt-get install -y -qq ansible
else
    echo "  already installed"
fi

echo "[6/6] Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $SUDO_USER
else
    echo "  already installed"
fi

echo ""
echo "Done. Versions:"
echo "  LXD:       $(lxd --version 2>/dev/null || echo 'not configured')"
echo "  Terraform: $(terraform version -json 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo 'n/a')"
echo "  Ansible:   $(ansible --version 2>/dev/null | head -1 | awk '{print $2}' || echo 'n/a')"
echo "  Docker:    $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',' || echo 'n/a')"
echo ""
echo "Next:"
echo "  1. lxd init (accept defaults)"
echo "  2. Log out/in (docker group)"
echo "  3. make vault"
echo "  4. make deploy"
