# resource "cloudca_port_forwarding_rule" "replicated_test_allow_argocd" {
#   environment_id     = var.environment_id
#   public_ip_id       = cloudca_public_ip.nat_ip.id
#   public_port_start  = 443
#   private_ip_id      = cloudca_instance.rke_test_worker[0].private_ip_id
#   private_port_start = 30384
#   protocol           = "TCP"
# }
#
# resource "cloudca_instance" "rke_test_leader" {
#   environment_id         = var.environment_id
#   name                   = "rke-leader"
#   network_id             = cloudca_network.network.id
#   template               = "97a20c63-6aad-4565-a7cc-e95bb16f5485"
#   compute_offering       = "Standard"
#   cpu_count              = 2
#   memory_in_mb           = 4096
#   ssh_key_name           = "sandbox-default"
#   root_volume_size_in_gb = 100
#   private_ip             = cidrhost(cloudca_network.network.cidr, 50)
#   # user_data              = templatefile("cloud-init.yaml", { public_key = var.public_key, passwd = base64sha256(var.password) })
# }
#
# resource "cloudca_instance" "rke_test_worker" {
#   count                  = 2
#   environment_id         = var.environment_id
#   name                   = format("rke-worker-%s", count.index)
#   network_id             = cloudca_network.network.id
#   template               = "97a20c63-6aad-4565-a7cc-e95bb16f5485"
#   compute_offering       = "Standard"
#   cpu_count              = 4
#   memory_in_mb           = 8192
#   ssh_key_name           = "sandbox-default"
#   root_volume_size_in_gb = 100
#   private_ip             = cidrhost(cloudca_network.network.cidr, count.index + 100)
#   # user_data              = templatefile("cloud-init.yaml", { public_key = var.public_key, passwd = base64sha256(var.password) })
# }
#
# resource "rke_cluster" "test_cluster" {
#   cluster_name       = "rke-workshop-test"
#   kubernetes_version = "v1.21.12-rancher1-1"
#
#   bastion_host {
#     address      = cloudca_public_ip.nat_ip.ip_address
#     user         = "student"
#     ssh_key_path = "/home/pwolthausen/.ssh/id_rsa"
#   }
#
#   nodes {
#     address          = cloudca_instance.rke_test_leader.private_ip
#     node_name        = "rke-test-leader-01"
#     internal_address = cloudca_instance.rke_test_leader.private_ip
#     user             = "student"
#     ssh_key_path     = "/home/pwolthausen/.ssh/id_rsa"
#     role             = ["controlplane", "etcd"]
#   }
#   dynamic "nodes" {
#     for_each = { for idx, node in cloudca_instance.rke_test_worker : idx => node }
#     content {
#       address          = nodes.value.private_ip
#       node_name        = format("rke-test-worker-%02v", nodes.key + 1)
#       internal_address = nodes.value.private_ip
#       user             = "student"
#       ssh_key_path     = "/home/pwolthausen/.ssh/id_rsa"
#       role             = ["worker"]
#     }
#   }
#   depends_on = [cloudca_port_forwarding_rule.replicated_test_allow_ssh_leader]
# }
#
# resource "null_resource" "master_config" {
#   depends_on = [rke_cluster.test_cluster]
#
#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p ~/.kube"
#     ]
#   }
#   provisioner "file" {
#     content     = rke_cluster.test_cluster.kube_config_yaml
#     destination = "/home/student/.kube/config"
#   }
#   connection {
#     type        = "ssh"
#     user        = "student"
#     host        = cloudca_public_ip.nat_ip.ip_address
#     private_key = file("/home/pwolthausen/.ssh/id_rsa")
#   }
# }
#
# resource "null_resource" "argocd" {
#   depends_on = [null_resource.master_config]
#
#   provisioner "remote-exec" {
#     inline = [
#       "kubectl create namespace argocd"
#     ]
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
#     ]
#   }
#   connection {
#     type        = "ssh"
#     user        = "student"
#     host        = cloudca_public_ip.nat_ip.ip_address
#     private_key = file("/home/pwolthausen/.ssh/id_rsa")
#   }
# }
