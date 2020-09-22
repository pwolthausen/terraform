output "vm_private_ip" {
  description = "internal ip of the vm"
  value       = coalesce("${google_compute_instance.server[0].network_interface[0].network_ip}", "${google_compute_instance.serverplusdisk[0].network_interface[0].network_ip}")
}

output "vm_name" {
  description = "name of the instance being created"
  value       = coalesce("${google_compute_instance.server[0].name}", "${google_compute_instance.serverplusdisk[0].name}")
}
