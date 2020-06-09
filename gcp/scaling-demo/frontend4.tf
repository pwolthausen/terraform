##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
####Frontend group 4
##Create snapshot schedule and attach schedule to a disk
#Boot disk
resource "google_compute_disk" "frontend4-boot" {
  count = "${var.frontend4count}"

  name  = "${format("frontend4-boot-%01d", count.index + 1)}"
  zone  = "${var.zone2_2}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "frontend4-boot" {
  count = "${var.frontend4count}"

  zone = "${var.zone2_2}"
  name = "${google_compute_resource_policy.daily_backup_west.name}"
  disk = "${google_compute_disk.frontend4-boot[count.index].name}"
}

#Data disk
resource "google_compute_disk" "frontend4-data" {
  count = "${var.frontend4count}"

  name = "${format("frontend4-data-%01d", count.index + 1)}"
  zone = "${var.zone2_2}"
  size = "${var.frontend_disk}"
  type = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "frontend4" {
  count = "${var.frontend4count}"

  zone = "${var.zone2_2}"
  name = "${google_compute_resource_policy.daily_backup_west.name}"
  disk = "${google_compute_disk.frontend4-data[count.index].name}"
}

#Create frontend4 instances
resource "google_compute_instance" "frontend4" {
  count = "${var.frontend4count}"

  name         = "${format("frontend4-%01d", count.index + 1)}"
  description  = "frontend4 server"
  zone         = "${var.zone2_2}"
  machine_type = "${var.frontend_machine_type}"
  tags         = ["http"]

  allow_stopping_for_update = true

  boot_disk {
    source = "${google_compute_disk.frontend4-boot[count.index].self_link}"
  }

  attached_disk {
    source = "${google_compute_disk.frontend4-data[count.index].self_link}"
  }

  metadata = {
    startup-script = "#! /bin/bash\napt update -y\napt install nginx -y"
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["logging-write"]
  }
}
#Create instance group
resource "google_compute_instance_group" "frontend4" {
  name        = "frontend4"
  description = "unamanged group of instances in zone 1_1"
  zone        = "${var.zone2_2}"
  instances   = "${google_compute_instance.frontend4.*.self_link}"
  network     = "${data.google_compute_network.default.self_link}"
}
