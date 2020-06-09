##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
####backend group1
##Create snapshot schedule and attach schedule to a disk
#Boot disk
resource "google_compute_disk" "backend3-boot" {
  count = "${var.backend3count}"

  name  = "${format("backend3-boot-%01d", count.index + 1)}"
  zone  = "${var.zone2_1}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend3-boot" {
  count = "${var.backend3count}"

  zone = "${var.zone2_1}"
  name = "${google_compute_resource_policy.daily_backup_west.name}"
  disk = "${google_compute_disk.backend3-boot[count.index].name}"
}

#Data disk
resource "google_compute_disk" "backend3-data" {
  count = "${var.backend3count}"

  name = "${format("backend3-data-%01d", count.index + 1)}"
  zone = "${var.zone2_1}"
  size = "${var.backend_disk}"
  type = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend3" {
  count = "${var.backend3count}"

  zone = "${var.zone2_1}"
  name = "${google_compute_resource_policy.daily_backup_west.name}"
  disk = "${google_compute_disk.backend3-data[count.index].name}"
}

#Create backend3 instances
resource "google_compute_instance" "backend3" {
  count = "${var.backend3count}"

  name         = "${format("backend3-%01d", count.index + 1)}"
  description  = "backend3 server"
  zone         = "${var.zone2_1}"
  machine_type = "${var.backend_machine_type}"
  tags         = ["http"]

  allow_stopping_for_update = true

  boot_disk {
    source = "${google_compute_disk.backend3-boot[count.index].self_link}"
  }

  attached_disk {
    source = "${google_compute_disk.backend3-data[count.index].self_link}"
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["logging-write"]
  }
}
#Create instance group
resource "google_compute_instance_group" "backend3" {
  name        = "backend3"
  description = "unamanged group of instances in zone 1_1"
  zone        = "${var.zone2_1}"
  instances   = "${google_compute_instance.backend3.*.self_link}"
  network     = "${data.google_compute_network.default.self_link}"
}
