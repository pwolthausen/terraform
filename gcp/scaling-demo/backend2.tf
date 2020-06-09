##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
####backend group 2
##Create snapshot schedule and attach schedule to a disk
#Boot disk
resource "google_compute_disk" "backend2-boot" {
  count = "${var.backend2count}"

  name  = "${format("backend2-boot-%01d", count.index + 1)}"
  zone  = "${var.zone1_2}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend2-boot" {
  count = "${var.backend2count}"

  zone = "${var.zone1_2}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.backend2-boot[count.index].name}"
}

#Data disk
resource "google_compute_disk" "backend2-data" {
  count = "${var.backend2count}"

  name = "${format("backend2-data-%01d", count.index + 1)}"
  zone = "${var.zone1_2}"
  size = "${var.backend_disk}"
  type = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend2" {
  count = "${var.backend2count}"

  zone = "${var.zone1_2}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.backend2-data[count.index].name}"
}

#Create backend2 instances
resource "google_compute_instance" "backend2" {
  count = "${var.backend2count}"

  name         = "${format("backend2-%01d", count.index + 1)}"
  description  = "backend2 server"
  zone         = "${var.zone1_2}"
  machine_type = "${var.backend_machine_type}"
  tags         = ["http"]

  allow_stopping_for_update = true

  boot_disk {
    source = "${google_compute_disk.backend2-boot[count.index].self_link}"
  }

  attached_disk {
    source = "${google_compute_disk.backend2-data[count.index].self_link}"
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["logging-write"]
  }
}
#Create instance group
resource "google_compute_instance_group" "backend2" {
  name        = "backend2"
  description = "unamanged group of instances in zone 1_1"
  zone        = "${var.zone1_2}"
  instances   = "${google_compute_instance.backend2.*.self_link}"
  network     = "${data.google_compute_network.default.self_link}"
}
