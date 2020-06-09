####Load balancer for backends
##Global forwarding rule
resource "google_compute_global_forwarding_rule" "backend" {
  name       = "backends"
  target     = "${google_compute_target_http_proxy.backend.self_link}"
  port_range = "80"
  ip_address = "${var.backendIP}"
}
##targetHttpProxy
resource "google_compute_target_http_proxy" "backend" {
  name    = "backends"
  url_map = "${google_compute_url_map.backend.self_link}"
}
##urlMap
resource "google_compute_url_map" "backend" {
  name            = "backends"
  default_service = "${google_compute_backend_service.backend.self_link}"
}
##Backend service
resource "google_compute_backend_service" "backend" {
  name          = "backends"
  health_checks = ["${google_compute_http_health_check.backend.self_link}"]
  backend {
    group = "${google_compute_instance_group.backend1.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.backend2.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.backend3.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.backend4.self_link}"
  }
}
##HTTP health check
resource "google_compute_http_health_check" "backend" {
  name         = "backend-hc"
  request_path = "/"
}
##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
####backend group1
##Create snapshot schedule and attach schedule to a disk
#Boot disk
resource "google_compute_disk" "backend1-boot" {
  count = "${var.backend1count}"

  name  = "${format("backend1-boot-%01d", count.index + 1)}"
  zone  = "${var.zone1_1}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend1-boot" {
  count = "${var.backend1count}"

  zone = "${var.zone1_1}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.backend1-boot[count.index].name}"
}

#Data disk
resource "google_compute_disk" "backend1-data" {
  count = "${var.backend1count}"

  name = "${format("backend1-data-%01d", count.index + 1)}"
  zone = "${var.zone1_1}"
  size = "${var.backend_disk}"
  type = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "backend1" {
  count = "${var.backend1count}"

  zone = "${var.zone1_1}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.backend1-data[count.index].name}"
}

#Create backend1 instances
resource "google_compute_instance" "backend1" {
  count = "${var.backend1count}"

  name         = "${format("backend1-%01d", count.index + 1)}"
  description  = "backend1 server"
  zone         = "${var.zone1_1}"
  machine_type = "${var.backend_machine_type}"
  tags         = ["http"]

  allow_stopping_for_update = true

  metadata = {
    startup-script = "#! /bin/bash \n apt update -y \n apt install nginx"
  }

  boot_disk {
    source = "${google_compute_disk.backend1-boot[count.index].self_link}"
  }

  attached_disk {
    source = "${google_compute_disk.backend1-data[count.index].self_link}"
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["logging-write"]
  }
}
#Create instance group
resource "google_compute_instance_group" "backend1" {
  name        = "backend1"
  description = "unamanged group of instances in zone 1_1"
  zone        = "${var.zone1_1}"
  instances   = "${google_compute_instance.backend1.*.self_link}"
  network     = "${data.google_compute_network.default.self_link}"
}
