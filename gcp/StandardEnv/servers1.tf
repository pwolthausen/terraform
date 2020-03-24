provider "google" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}

resource "google_compute_health_check" "servers1_autohealing" {
  name                = "${var.servers1}-HC"
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

##Define the template to be used by the first MIG. If a template change is required, copy this resource and make the changes, do not update template resources
data "google_compute_image" "my_image" {
  family  = "${var.servers1_image_family}"
  project = "${var.servers1_image_project}"
}

data "google_compute_image" "blank" {
  family    = "blank"
}

resource "google_compute_instance_template" "servers1_template" {
  name         = "${var.servers1}-template"
  tags         = [""]
  machine_type = "${var.servers1_machine_type}"

  disk {
    source_image = "${google_compute_image.my_image.self_link}"
    auto_delete  = false
    boot         = true
    disk_size_gb = ""
    disk_type =
  }

  disk {
    auto-delete = false
    boot = false
    source_image = "${google_compute_image.blank.self_link}"
    disk_size_gb = ""
    disk_type = ""
  }

  labels {
    env  = "${var.servers1_env}"
    role = "${var.servers1_role}"
  }

  network_interface {
    network = "${google_compute_network.newVPC.self_link}"
  }

  service_account {
    scopes = [""]
  }
}

##The Managed Instance Group (MIG) that will maintain the server. This allows for automatic restarts and auto-healing.
resource "google_compute_instance_group_manager" "servers1" {
  name               = "${var.servers1}-igm"
  base_instance_name = "${var.servers1}"
  zone               = "${var.zone}"

  target_size = "${var.server1_replicas}"

  version {
    instance_template = "${google_compute_instance_template.servers1_template.self_link}"
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
