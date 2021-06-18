##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#disks
resource "google_compute_disk" "root" {
  name  = "${var.serverName}-${var.env}"
  zone  = var.zone
  image = var.image
  size  = var.root_disk
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "root" {
  zone = var.zone
  name = var.snapshotPolicy
  disk = google_compute_disk.server-1.name
}

##Note that additional disks do not require an image
resource "google_compute_disk" "add_disk" {
  for_each = var.addDisk
  name     = "${var.serverName}-data-${var.env}"
  zone     = var.zone
  size     = each.value.size
  type     = each.value.type
}

resource "google_compute_disk_resource_policy_attachment" "add_disk" {
  for_each = var.addDisk
  zone     = var.zone
  name     = var.snapshotPolicy
  disk     = google_compute_disk.add_disk[each.key].name
}

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#server
resource "google_compute_instance" "server" {
  name         = "${var.env}-${var.serverName}"
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

  dynamic "network_interface" {
    for_each = var.network_if
    content {
      subnetwork = each.value.subnet
      network_ip = each.value.internal_ip
    }
  }

  service_account {
    scopes = ["logging-write"]
  }
}
