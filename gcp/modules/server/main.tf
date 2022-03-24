##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#disks
resource "google_compute_disk" "root" {
  project = var.project_id
  name    = "${var.serverName}-root"
  zone    = var.zone
  image   = var.image
  size    = var.root_disk_size
  type    = var.root_disk_type
}

resource "google_compute_disk_resource_policy_attachment" "root" {
  count = var.snapshotPolicy == null ? 0 : 1
  project = var.project_id
  zone    = var.zone
  name    = var.snapshotPolicy
  disk    = google_compute_disk.root.name
}

##Note that additional disks do not require an image
resource "google_compute_disk" "add_disk" {
  for_each = var.addDisk
  project  = var.project_id
  name     = "${var.serverName}-data-${each.key}"
  zone     = var.zone
  size     = each.value.size
  type     = each.value.type
}

resource "google_compute_disk_resource_policy_attachment" "add_disk" {
  for_each = var.snapshotPolicy == null ? {} : var.addDisk
  project  = var.project_id
  zone     = var.zone
  name     = var.snapshotPolicy
  disk     = google_compute_disk.add_disk[each.key].name
}

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#server
resource "google_compute_instance" "server" {
  project      = var.project_id
  name         = var.serverName
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.root.self_link
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.add_disk
    content {
      source = google_compute_disk.add_disk[each.key].self_link
    }
  }

  network_interface {
    network    = var.network
    network_ip = google_compute_address.internal_static.address
    subnetwork = var.subnet == null ? null : "projects/${local.network_project}/regions/${var.region}/subnetworks/${var.subnet}"
    dynamic "access_config" {
      for_each = toset(google_compute_address.external_static)
      content {
        nat_ip       = access_config.value.address
        network_tier = "PREMIUM"
      }
    }
  }

  service_account {
    scopes = ["logging-write"]
  }
}

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
# resources will create inetrnal and external static IPs which will be attached to each VM.
resource "google_compute_address" "internal_static" {
  project = var.project_id
  region  = var.region

  name         = "${var.serverName}-int-ip"
  subnetwork   = "projects/${local.network_project}/regions/${var.region}/subnetworks/${var.subnet}"
  address_type = "INTERNAL"
  address      = var.internal_ip
}

resource "google_compute_address" "external_static" {
  count   = var.external_ip != null ? 1 : 0
  project = var.project_id
  region  = var.region

  name         = "${var.serverName}-ext-ip"
  address_type = "EXTERNAL"
}

locals {
  network         = var.network == null ? null : split("/", var.network)
  network_project = var.network == null ? null : local.network[1]
}
