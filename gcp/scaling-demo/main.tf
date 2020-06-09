provider "google" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}

resource "google_compute_project_metadata" "project_wide_ssh_keys" {
  metadata = {
    ssh-keys = "demo:${var.demo_pub_key}"
  }
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  description  = "bastion server"
  zone         = "${var.zone1_1}"
  machine_type = "custom-1-2048"
  tags         = ["bastion"]

  allow_stopping_for_update = true

  boot_disk {
    source = "${google_compute_disk.bastion.self_link}"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip       = "${var.bastionIP}"
      network_tier = "STANDARD"
    }
  }

  service_account {
    scopes = []
  }
}

data "google_compute_image" "ubuntu" {
  family  = "${var.server_image_family}"
  project = "${var.server_image_project}"
}

data "google_compute_network" "default" {
  name = "default"
}

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
##Create snapshot schedule and attach schedule to a disk

resource "google_compute_resource_policy" "daily_backup_central" {
  name   = "daily-backup-central"
  region = "${var.region1}"
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 22
        start_time     = "23:00"
      }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }
    snapshot_properties {
      storage_locations = ["us"]
      guest_flush       = true
    }
  }
}

resource "google_compute_resource_policy" "daily_backup_west" {
  name   = "daily-backup-west"
  region = "${var.region2}"
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 22
        start_time     = "23:00"
      }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }
    snapshot_properties {
      storage_locations = ["us"]
      guest_flush       = true
    }
  }
}

resource "google_compute_disk" "bastion" {
  name  = "bastion-disk"
  zone  = "${var.zone1_1}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-standard"
}

resource "google_compute_disk_resource_policy_attachment" "bastion" {
  zone = "${var.zone1_1}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.bastion.name}"
}
