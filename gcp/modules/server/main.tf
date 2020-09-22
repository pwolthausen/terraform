##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#server
resource "google_compute_instance" "server" {
  count        = var.addDisk ? 0 : 1
  name         = "${var.serverName}-${var.env}"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tag
  hostname     = "${var.serverName}-${var.env}.${var.client}"

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.server-1.self_link
  }

  network_interface {
    subnetwork = var.subnet
    network_ip = var.intip
  }

  service_account {
    scopes = ["logging-write"]
  }
}

resource "google_compute_instance" "serverplusdisk" {
  count        = var.addDisk ? 1 : 0
  name         = "${var.serverName}-${var.env}"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tag

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.server-1.self_link
  }

  attached_disk {
    source = google_compute_disk.server-2[count.index].self_link
  }

  network_interface {
    subnetwork = var.subnet
    network_ip = var.intip
  }

  service_account {
    scopes = ["logging-write"]
  }
}
##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
#disks
resource "google_compute_disk" "server-1" {
  name  = "${var.serverName}-${var.env}"
  zone  = var.zone
  image = var.image
  size  = var.disk1_size
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "server-1" {
  zone = var.zone
  name = var.snapshotPolicy
  disk = google_compute_disk.server-1.name
}

##Note that additional disks do not require an image
resource "google_compute_disk" "server-2" {
  count = var.addDisk ? 1 : 0
  name  = "${var.serverName}-data-${var.env}"
  zone  = var.zone
  size  = var.disk2_size
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "server1-2_prod" {
  count = var.addDisk ? 1 : 0
  zone  = var.zone
  name  = var.snapshotPolicy
  disk  = google_compute_disk.server-2[count.index].name
}
