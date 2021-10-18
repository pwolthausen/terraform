packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "project_id" {
  type = string
}

variable "windows_image" {
  type    = string
  default = "windows-server-2019-dc-v20200813"
}

variable "linux_image" {
  type    = string
  default = "debian-9-stretch-v20200805"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-2"
}

variable "windows_password" {
  type = string
}

locals {
  timestamp = formatdate("DDMMYYYY", timestamp())
}

source "googlecompute" "basic-example" {
  project_id   = var.project_id
  source_image = var.linux_image
  ssh_username = "packer-linux-example-${local.timestamp}"
  zone         = var.zone
  tags         = ["packer"]
}

source "googlecompute" "windows-example" {
  project_id     = var.project_id
  source_image   = var.windows_image
  image_name     = "packer-windows-example-${local.timestamp}"
  zone           = var.zone
  disk_size      = 50
  machine_type   = var.machine_type
  communicator   = "winrm"
  winrm_username = "packer_user"
  winrm_insecure = true
  winrm_use_ssl  = true
  tags           = ["packer"]
  metadata = {
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
}

build {
  sources = ["sources.googlecompute.windows-example"]

  provisioner "powershell" {
    elevated_user     = "packer_user"
    elevated_password = build.Password
    environment_vars  = ["PASSWORD=${var.windows_password}"]
    inline            = ["New-LocalUser \"packerTest\" -Password $PASSWORD"]
  }

  provisioner "windows-update" {}

  provisioner "powershell" {
    elevated_user     = "packer_user"
    elevated_password = build.Password
    script = "./scripts/addRoles.ps1"
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = "packer_user"
    elevated_password = build.Password
    scripts = ["./scripts/disable_ie_security.ps1", "./scripts/configure_sftp.ps1"]
  }

  provisioner "windows-restart" {}

  provisioner "file" {
    source      = "./files/app_info.html"
    destination = "C:\\Documents"
  }

  provisioner "powershell" {
    elevated_user     = "packer_user"
    elevated_password = build.Password
    script = "./scripts/disable_winrm.ps1"
  }
}