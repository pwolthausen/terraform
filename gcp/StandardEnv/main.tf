provider "google" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}

## Add project wide pub;ic SSH keys. Default will add automation ssh key and client admin key. Other client keys can be added if provided.
resource "google_compute_project_metadata" "default" {
  metadata = {
    ssh-keys = "automation:${var.automation_key}\nadmin:${var.client_admin_key}"
  }
}
