resource "google_service_account" "gke_service_account" {
  count        = var.service_account_email == null ? 1 : 0
  account_id   = "sa-gke-${var.domain}-${var.env}-${var.usecase}-${var.index}"
  display_name = "sa-gke-${var.domain}-${var.env}-${var.usecase}-${var.index}"
}

resource "google_project_iam_member" "gke_sa_storage" {
  count   = var.service_account_email == null ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account[0].email}"
}

resource "google_project_iam_member" "gke_sa_monitoring" {
  count   = var.service_account_email == null ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_service_account[0].email}"
}

resource "google_project_iam_member" "gke_sa_monitoring_1" {
  count   = var.service_account_email == null ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_service_account[0].email}"
}

resource "google_project_iam_member" "gke_sa_logging" {
  count   = var.service_account_email == null ? 1 : 0
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_service_account[0].email}"
}

locals {
  sa_roles     = var.service_account_email == null ? toset([]) : toset(var.service_account_roles)
  gke_sa_email = var.service_account_email == null ? google_service_account.gke_service_account[0].email : var.service_account_email
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = local.sa_roles
  project  = var.project_id
  role     = "roles/${each.key}"
  member   = "serviceAccount:${google_service_account.gke_service_account[0].email}"
}