output "leader_names" {
  description = "List of leader node names"
  value       = cloudca_instance.leader.*.name
}
output "leader_ips" {
  description = "List of leader node ips"
  value       = cloudca_instance.leader.*.private_ip
}

output "worker_names" {
  description = "List of worker names"
  value       = cloudca_instance.worker.*.name
}
output "worker_ips" {
  description = "List of worker ips"
  value       = cloudca_instance.worker.*.private_ip
}

output "worker_st_names" {
  description = "List of worker_st names"
  value       = cloudca_instance.worker_st.*.name
}
output "worker_st_ips" {
  description = "List of worker_st ips"
  value       = cloudca_instance.worker_st.*.private_ip
}

resource "local_file" "rke-cluster" {
  content = templatefile("${path.module}/cluster.tmpl",
    {
      leader_names    = cloudca_instance.leader.*.name
      leader_ips      = cloudca_instance.leader.*.private_ip
      worker_names    = cloudca_instance.worker.*.name
      worker_ips      = cloudca_instance.worker.*.private_ip
      worker_st_names = cloudca_instance.worker_st.*.name
      worker_st_ips   = cloudca_instance.worker_st.*.private_ip
      cluster_fqdn    = var.cluster_fqdn
      cluster_name    = var.cluster_name
      s3_access_key   = var.s3_access_key
      s3_secret_key   = var.s3_secret_key
      k8s_version     = var.k8s_version
      k8s_ingress     = var.k8s_ingress
      k8s_cni         = var.k8s_cni
  })
  filename = "cluster.yml"
}
