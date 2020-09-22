resource "google_compute_health_check" "servers1_autohealing" {
  name                = "${var.name}-hc"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    request_path = var.hcpath
    response     = var.response
    port         = var.hcport
  }

resource "google_compute_instance_template" "server_template" {
  count        = var.disk2 ? 0 : 1
  name         = "${var.name}-template"
  tags         = var.tags
  machine_type = var.machine_type

  disk {
    source_image = "${data.google_compute_image.my_image.self_link}"
    auto_delete  = false
    boot         = true
    disk_size_gb = var.disk1_size
    disk_type    = var.disk1_type
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
  }
  ##Note the servers are created without scopes to start with. If the server will need either scopes or a custom service account, this section will need to be changed
  service_account {
    scopes = ["logging-write"]
  }
}

resource "google_compute_instance_template" "serverplusdisk_template" {
  count        = var.disk2 ? 1 : 0
  name         = "${var.name}-template"
  tags         = var.tags
  machine_type = var.machine_type

  disk {
    source_image = var.image
    auto_delete  = false
    boot         = true
    disk_size_gb = var.disk1_size
    disk_type    = var.disk1_type
  }
  disk {
    auto_delete  = false
    boot         = false
    disk_size_gb = var.disk2_size
    disk_type    = var.disk2_type
  }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
  }
  metadata_startup_script = ""

  ##Note the servers are created without scopes to start with. If the server will need either scopes or a custom service account, this section will need to be changed
  service_account {
    scopes = ["logging-write"]
  }
}

##The Managed Instance Group (MIG) that will maintain the server. This allows for automatic restarts and auto-healing.
resource "google_compute_instance_group_manager" "server" {
  count              = var.disk2 ? 0 : 1
  name               = "${var.name}-igm"
  base_instance_name = var.name
  zone               = var.zone
  target_size        = var.replicas

  version {
    instance_template = google_compute_instance_template.server_template[0].self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 60
  }
}
resource "google_compute_instance_group_manager" "serverplusdisk" {
  count              = var.disk2 ? 1 : 0
  name               = "${var.name}-igm"
  base_instance_name = var.name
  zone               = var.zone
  target_size        = var.replicas

  version {
    instance_template = google_compute_instance_template.serverplusdisk_template[0].self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 60
  }
}


####Load balancer for MIG
##HTTP health check
resource "google_compute_http_health_check" "glb" {
  name         = "${var.name}-hc"
  request_path = var.hcpath
}
##Global IP for GLB
resource "google_compute_global_address" "glb" {
  name = var.name
}
##Backend service
resource "google_compute_backend_service" "glb" {
  count         = var.disk2 ? 0 : 1
  name          = var.name
  health_checks = ["${google_compute_http_health_check.glb.self_link}"]
  backend {
    group = google_compute_instance_group_manager.server[0].self_link
  }
}
resource "google_compute_backend_service" "glbplusdisk" {
  count         = var.disk2 ? 1 : 0
  name          = var.name
  health_checks = ["${google_compute_http_health_check.glb.self_link}"]
  backend {
    group = google_compute_instance_group_manager.serverplusdisk[0].self_link
  }
}
##urlMap
resource "google_compute_url_map" "glb" {
  name            = var.name
  default_service = google_compute_backend_service.glb.self_link
}
##targetHttpProxy
resource "google_compute_target_http_proxy" "glb" {
  name    = var.name
  url_map = google_compute_url_map.glb.self_link
}
##Global forwarding rule
resource "google_compute_global_forwarding_rule" "glb" {
  name       = var.name
  target     = google_compute_target_http_proxy.glb.self_link
  port_range = "80"
  ip_address = google_compute_global_address.glb.address
}
