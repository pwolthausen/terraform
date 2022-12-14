output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "gke_service_account" {
  value       = local.gke_sa_email
  description = "Compute service account used by the cluster"
}

output "endpoint" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE API endpoint"
}

output "ca_certificate" {
  value = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
  description = "base64 encoded ca certificate for the cluster"
}