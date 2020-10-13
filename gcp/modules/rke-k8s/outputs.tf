output "master_ips" {
  value = google_compute_instance.master.*.network_interface.access_config.nat_ip
}
output "master_private_ips" {
  value = google_compute_instance.master.*.network_interface.network_ip
}
output "worker_ips" {
  value = google_compute_instance.worker.*.network_interface.access_config.nat_ip
}
output "worker_private_ips" {
  value = google_compute_instance.worker.*.network_interface.network_ip
}
output "worker_st_ips" {
  value = google_compute_instance.worker_st.*.network_interface.access_config.nat_ip
}
output "worker_st_private_ips" {
  value = google_compute_instance.worker_st.*.network_interface.network_ip
}

resource "local_file" "rke-cluster" {
  content = templatefile("${path.module}/cluster.tmpl",
    {
      master_ips            = google_compute_instance.master.*.network_interface.access_config.nat_ip
      master_private_ips    = google_compute_instance.master.*.network_interface.network_ip
      worker_ips            = google_compute_instance.worker.*.network_interface.access_config.nat_ip
      worker_private_ips    = google_compute_instance.worker.*.network_interface.network_ip
      worker_st_ips         = google_compute_instance.worker_st.*.network_interface.access_config.nat_ip
      worker_st_private_ips = google_compute_instance.worker_st.*.network_interface.network_ip
      cluster_name          = var.cluster_name
      k8s_version           = var.k8s_version
      k8s_ingress           = var.k8s_ingress
      k8s_cni               = var.k8s_cni
  })
  filename = "cluster.yml"
}
