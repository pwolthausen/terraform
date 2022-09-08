#cloud-config

package_update: true
package_upgrade: true

packages:
  - vim
  - bash-completion
  - curl
  - software-properties-common
  - wget
  - jq
  - nginx
  - chrony

ntp:
  enabled: true

users:
  - name: pwolthausen
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: admin
    lock_passwd: false
    shell: /bin/bash
    ssh_authorized_keys:
      - "${public_key}"
