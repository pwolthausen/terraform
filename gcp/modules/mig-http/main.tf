resource "google_compute_health_check" "autohealing" {
  name                = "${var.name}-hc"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    request_path = var.hc.path
    response     = var.hc.response
    port         = var.hc.port
  }
}

resource "google_compute_instance_template" "server_template" {
  name         = "${var.name}-template"
  tags         = var.tags
  machine_type = var.machine_type

  disk {
    source_image = var.image
    auto_delete  = false
    boot         = true
    disk_size_gb = var.disk_size
    disk_type    = var.disk_type
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

resource "google_compute_autoscaler" "server" {
  name   = "${var.name}-${var.zone}"
  zone   = var.zone
  target = google_compute_instance_group_manager.server.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_preiod = var.cooldown_preiod
  }
}

resource "google_compute_target_pool" "server" {
  name = "${var.name}-${var.zone}-pool"
}

resource "google_compute_instance_group_manager" "server" {
  name               = "${var.name}-${var.zone}-igm"
  base_instance_name = var.name
  zone               = var.zone
  target_pools       = google_compute_target_pool.server.id

  version {
    instance_template = google_compute_instance_template.server_template.self_link
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