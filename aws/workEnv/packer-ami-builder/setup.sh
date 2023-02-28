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
    ntp vim jq python3 python3-pip \
    apparmor apparmor-utils auditd \
    fail2ban unattended-upgrades

if ! systemctl is-enabled --quiet ntp.service; then
  sudo systemctl enable ntp.service
fi

if [ ! -e /usr/bin/pip ]; then
  sudo ln -s pip3 /usr/bin/pip
fi

sudo ln -sf /usr/bin/python3 /usr/bin/python

echo "Creating pressbooks and cloudops user and groups...."
sudo groupadd pressbooks
sudo groupadd cloudops
sudo useradd -m -g cloudops -s /bin/bash cloudops
sudo useradd -m -g pressbooks -s /bin/bash pressbooks-ops
sudo mkdir /home/pressbooks-ops/.ssh && sudo chown pressbooks-ops /home/pressbooks-ops/.ssh
sudo mkdir /home/cloudops/.ssh && sudo chown cloudops /home/cloudops/.ssh
sudo mv ~/jenkins.pub /home/pressbooks-ops/.ssh/authorized_keys && sudo chown pressbooks-ops /home/pressbooks-ops/.ssh/authorized_keys
sudo mv ~/cloudops.pub /home/cloudops/.ssh/authorized_keys && sudo chown cloudops /home/cloudops/.ssh/authorized_keys
sudo cp ~/bashrc /home/pressbooks-ops/.bashrc && sudo chown pressbooks-ops /home/pressbooks-ops/.bashrc
sudo mv ~/bashrc /home/cloudops/.bashrc && sudo chown cloudops /home/cloudops/.bashrc

sudo apt-get remove -y \
    nis rsh-server rsh-client talk \
    telnetd atftp tftpd xinetd echoping avahi-daemon cups acct

export SERVICES='rsh rlogin ypbind tftp certmonger cgconfig cgred cpuspeed  kdump mdmonitor messagebus netconsole ntpdate oddjobd portreserve qpidd quota_nld rdisc rhnsd rhsmcertd saslauthd smartd atd nfslock named dovecot squid snmpd rpcgssd rpcsvcgssd rpcidmap netfs nfs avahi-daemon'

for service in $SERVICES; do if sudo systemctl is-enabled --quiet $service;then sudo systemctl stop $service; sudo systemctl disable $service; fi; done

sudo unattended-upgrades -d

for service in cron irqbalance; do sudo systemctl enable $service; done

sudo rsync --remove-source-files --chown=root ~/sudoers /etc/sudoers
sudo mv ~/jail.local /etc/fail2ban/jail.local
sudo mv ~/fail2ban.local /etc/fail2ban/fail2ban.local
sudo mv ~/ssh_config /etc/ssh/ssh_config
sudo mv ~/sshd_config /etc/ssh/sshd_config
sudo mv ~/access.conf /etc/security/access.conf
