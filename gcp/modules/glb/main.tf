resource "google_compute_http_health_check" "glb" {
  name         = "${var.name}-hc"
  request_path = var.hcpath
}

resource "google_compute_global_address" "glb" {
  name = var.name
}

resource "google_compute_backend_service" "glb" {
  name          = var.name
  health_checks = ["${google_compute_http_health_check.glb.self_link}"]
  enable_cdn    = true
  backend {
    group = var.group
  }
}

resource "google_compute_url_map" "glb" {
  name            = var.name
  default_service = google_compute_backend_service.glb.self_link
}

resource "google_compute_target_http_proxy" "glb" {
  name    = var.name
  url_map = google_compute_url_map.glb.self_link
}

resource "google_compute_global_forwarding_rule" "glb" {
  name       = var.name
  target     = google_compute_target_http_proxy.glb.self_link
  port_range = "80"
  ip_address = google_compute_global_address.glb.address
}
