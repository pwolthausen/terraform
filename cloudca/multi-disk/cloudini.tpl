#cloud-config
package_update: true
packages:
  - cloud-utils-growpart
  - vim
  - system-storage-manager
  - lvm2
runcmd:
  - "while true; do if [ -d /dev/xvdb ]; then ssm create -n logs -p soc2 --fstype xfs /dev/xvdb /var/log ; continue ; fi ; done"
  - "sleep 1"
  - "while true; do if [ -d /dev/xvdc ]; then ssm create -n homes -p home_dirs --fs xfs /dev/xvdX /mnt/ ; continue ; fi ; done"
  - "sleep 1"
  - "mv /home/* /mnt/"
  - "umount /mnt/"
  - "while true; do if [ -d /dev/xvde ]; then ssm create -n cloudmc -p data --fstype xfs /dev/xvde /data ; continue ; fi ; done"
  - "sleep 1"
  - "mount /dev/soc2/home"
mounts:
  - [ /dev/soc2/logs, /var/log, "xfs", "defaults", "0", "0" ]
  - [ /dev/soc2/home, /home, "xfs", "defaults", "0", "0" ]
  - [ /dev/data/sql, /data, "xfs", "defaults", "0", "0" ]
users:
  - name: ops-jenkins
    primary_group: ops-jenkins
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    groups: adm
    ssh_authorized_keys: ""
