output "instance_private_ip" {
  description = "internal ip of the vm"
  value       = google_compute_instance.server.network_interface[0].network_ip
}

output "instance_public_ip" {
  value = var.external_ip != null ? google_compute_instance.server.network_interface[0].access_config[0].nat_ip : null
}

output "instance_name" {
  description = "name of the instance being created"
  value       = google_compute_instance.server.name
}

output "instance_self_link" {
  value = google_compute_instance.server.self_link
}
