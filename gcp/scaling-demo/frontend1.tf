####Load balancer for frontends
##Global forwarding rule
resource "google_compute_global_forwarding_rule" "frontend" {
  name       = "frontends"
  target     = "${google_compute_target_http_proxy.frontend.self_link}"
  port_range = "80"
  ip_address = "${var.frontendIP}"
}
##targetHttpProxy
resource "google_compute_target_http_proxy" "frontend" {
  name    = "frontends"
  url_map = "${google_compute_url_map.frontend.self_link}"
}
##urlMap
resource "google_compute_url_map" "frontend" {
  name            = "frontends"
  default_service = "${google_compute_backend_service.frontend.self_link}"
}
##Backend service
resource "google_compute_backend_service" "frontend" {
  name          = "frontends"
  health_checks = ["${google_compute_http_health_check.frontend.self_link}"]
  backend {
    group = "${google_compute_instance_group.frontend1.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.frontend2.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.frontend3.self_link}"
  }
  backend {
    group = "${google_compute_instance_group.frontend4.self_link}"
  }
}
##HTTP health check
resource "google_compute_http_health_check" "frontend" {
  name         = "frontend-hc"
  request_path = "/"
}
##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
####Frontend group1
##Create snapshot schedule and attach schedule to a disk
#Boot disk
resource "google_compute_disk" "frontend1-boot" {
  count = "${var.frontend1count}"

  name  = "${format("frontend1-boot-%01d", count.index + 1)}"
  zone  = "${var.zone1_1}"
  image = "${data.google_compute_image.ubuntu.self_link}"
  size  = "20"
  type  = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "frontend1-boot" {
  count = "${var.frontend1count}"

  zone = "${var.zone1_1}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.frontend1-boot[count.index].name}"
}

#Data disk
resource "google_compute_disk" "frontend1-data" {
  count = "${var.frontend1count}"

  name = "${format("frontend1-data-%01d", count.index + 1)}"
  zone = "${var.zone1_1}"
  size = "${var.frontend_disk}"
  type = "pd-ssd"
}

resource "google_compute_disk_resource_policy_attachment" "frontend1" {
  count = "${var.frontend1count}"

  zone = "${var.zone1_1}"
  name = "${google_compute_resource_policy.daily_backup_central.name}"
  disk = "${google_compute_disk.frontend1-data[count.index].name}"
}

#Create frontend1 instances
resource "google_compute_instance" "frontend1" {
  count = "${var.frontend1count}"

  name         = "${format("frontend1-%01d", count.index + 1)}"
  description  = "frontend1 server"
  zone         = "${var.zone1_1}"
  machine_type = "${var.frontend_machine_type}"
  tags         = ["http"]

  metadata = {
    startup-script = "#! /bin/bash\napt update -y\napt install nginx -y"
  }

  allow_stopping_for_update = true

  boot_disk {
    source = "${google_compute_disk.frontend1-boot[count.index].self_link}"
  }

  attached_disk {
    source = "${google_compute_disk.frontend1-data[count.index].self_link}"
  }

  network_interface {
    network = "default"
  }

  service_account {
    scopes = ["logging-write"]
  }
}
#Create instance group
resource "google_compute_instance_group" "frontend1" {
  name        = "frontend1"
  description = "unamanged group of instances in zone 1_1"
  zone        = "${var.zone1_1}"
  instances   = "${google_compute_instance.frontend1.*.self_link}"
  network     = "${data.google_compute_network.default.self_link}"
}
