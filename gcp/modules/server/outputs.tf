output "vm_private_ip" {
  description = "internal ip of the vm"
  value       = google_compute_instance.server.network_interface[0].network_ip
}

output "vm_name" {
  description = "name of the instance being created"
  value       = google_compute_instance.server.name
}
