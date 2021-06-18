provider "google" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}
