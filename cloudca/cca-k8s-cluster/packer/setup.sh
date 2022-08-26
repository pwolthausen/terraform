#!/usr/bin/env bash
set -euxo pipefail

echo "Due to intermittent failures in installing packes, rebuild lists first"
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -y || true
sudo apt-cache gencaches

echo "Installing updates and pre-requisites...."
sudo apt-get upgrade -y
sudo apt-get install -y \
    wget unzip dnsutils \
    ntp ca-certificates vim jq python3 python3-pip \
    apparmor apparmor-utils auditd docker.io

if ! systemctl is-enabled --quiet ntp.service; then
  sudo systemctl enable ntp.service
fi

if [ ! -e /usr/bin/pip ]; then
  sudo ln -s pip3 /usr/bin/pip
fi

sudo ln -sf /usr/bin/python3 /usr/bin/python

# Create group for ops team
sudo groupadd operations
sudo useradd -m -g operations -s /bin/bash automation
sudo mkdir /home/automation/.ssh && sudo chown automation /home/automation/.ssh
sudo mv ~/automation.pub /home/operations/.ssh/authorized_keys && sudo chown automation /home/automation/.ssh/authorized_keys

# Give docker access to automation
sudo usermod -aG docker automation

# Set kernel parameters for RKE
echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf > /dev/null

