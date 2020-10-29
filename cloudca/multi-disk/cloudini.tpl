#cloud-config
package_update: true
packages:
  - cloud-utils-growpart
  - vim
  - system-storage-manager
  - lvm2
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
