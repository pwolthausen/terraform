resource "google_compute_health_check" "servers1_autohealing" {
  name                = "${var.servers1}-hc"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  ##Choose and define the type of check. Only one type should be selected
  tcp_health_check {
    request  = "/"
    response = ""
    port     = 80
  }

  # ssl_health_check {
  #   request  = "/"
  #   response = ""
  #   port     = 80
  # }
  #
  # http_health_check {
  #   request_path = "/"
  #   response     = ""
  #   port         = 80
  # }
  #
  # https_health_check {
  #   request_path = "/"
  #   response     = ""
  #   port         = 80
  # }
}

data "google_compute_image" "my_image" {
  family  = "${var.servers1_image_family}"
  project = "${var.servers1_image_project}"
}
##Define the template to be used by the first MIG. If a template change is required, copy this resource and make the changes, do not update template resources
resource "google_compute_instance_template" "server1_template" {
  name         = "${var.servers1}-template"
  tags         = ["web-server"]
  machine_type = "${var.servers1_machine_type}"

  disk {
    source_image = "${data.google_compute_image.my_image.self_link}"
    auto_delete  = false
    boot         = true
    disk_size_gb = "${var.server1_bootdisk_size}"
    disk_type    = "pd-standard"
  }

  disk {
    auto_delete  = true
    boot         = false
    source_image = "${data.google_compute_image.my_image.self_link}"
    disk_size_gb = "${var.server1_datadisk_size}"
    disk_type    = "pd-standard"
  }

  labels = {
    env  = "${var.servers1_env}"
    role = "${var.servers1_role}"
  }

  network_interface {
    network    = "${google_compute_network.newVPC.self_link}"
    subnetwork = "${google_compute_subnetwork.newSubnets.self_link}"
  }
  ##Note the servers are created without scopes to start with. If the server will need either scopes or a custom service account, this section will need to be changed
  service_account {
    scopes = ["logging-write"]
  }
}

##The Managed Instance Group (MIG) that will maintain the server. This allows for automatic restarts and auto-healing.
resource "google_compute_instance_group_manager" "servers1" {
  name               = "${var.servers1}-igm"
  base_instance_name = "${var.servers1}"
  zone               = "${var.zone1}"

  target_size = "${var.server1_replicas}"

  version {
    instance_template = "${google_compute_instance_template.server1_template.self_link}"
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.servers1_autohealing.self_link}"
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 300
  }
}

####Load balancer for servers1s
##Global IP for GLB
resource "google_compute_global_address" "servers1" {
  name = "${var.servers1}"
}
##Global forwarding rule
resource "google_compute_global_forwarding_rule" "servers1" {
  name       = "${var.servers1}"
  target     = "${google_compute_target_http_proxy.servers1.self_link}"
  port_range = "80"
  ip_address = "${google_compute_global_address.servers1.address}"
}
##targetHttpProxy
resource "google_compute_target_http_proxy" "servers1" {
  name    = "${var.servers1}"
  url_map = "${google_compute_url_map.servers1.self_link}"
}
##urlMap
resource "google_compute_url_map" "servers1" {
  name            = "${var.servers1}"
  default_service = "${google_compute_backend_service.servers1.self_link}"
}
##Backend service
resource "google_compute_backend_service" "servers1" {
  name          = "${var.servers1}"
  health_checks = ["${google_compute_http_health_check.servers1.self_link}"]
  backend {
    group = "${google_compute_instance_group_manager.servers1.self_link}"
  }
}
##HTTP health check
resource "google_compute_http_health_check" "servers1" {
  name         = "${var.servers1}-hc"
  request_path = "/"
}
