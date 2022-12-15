# /******************************************
#   Create ip-masq-agent confimap
#  *****************************************/

# locals {
#   pod_cird_range       = [for x in data.google_compute_subnetwork.subnetwork.secondary_ip_range : x.ip_cidr_range if x.range_name == var.cluster_secondary_range]
#   service_cird_range   = [for x in data.google_compute_subnetwork.subnetwork.secondary_ip_range : x.ip_cidr_range if x.range_name == var.service_secondary_range]
#   non_masquerade_cidrs = concat(var.non_masquerade_cidrs, [data.google_compute_subnetwork.subnetwork.ip_cidr_range], local.pod_cird_range, local.service_cird_range)
# }

# resource "kubernetes_config_map" "ip-masq-agent" {
#   metadata {
#     name      = "ip-masq-agent"
#     namespace = "kube-system"

#     labels = {
#       maintained_by = "terraform"
#     }
#   }

#   data = {
#     config = <<EOF
# nonMasqueradeCIDRs:
#   - ${join("\n  - ", local.non_masquerade_cidrs)}
# resyncInterval: "60s"
# masqLinkLocal: false
# EOF
#   }

#   depends_on = [
#     google_container_cluster.cluster,
#     google_container_node_pool.pool,
#   ]
# }

# resource "helm_release" "external_dns" {
#   name             = "external-dns"
#   namespace        = "core"
#   create_namespace = true
#   repository       = "https://charts.bitnami.com/bitnami" #"https://prometheus-community.github.io/helm-charts"
#   chart            = "external-dns"                       #"kube-prometheus-stack"
#   version          = "6.10.2"                             #"41.5.0" / latest

#   timeout         = 900
#   cleanup_on_fail = true
#   atomic          = true

#   depends_on = [
#     google_container_cluster.cluster,
#     google_container_node_pool.pool,
#   ]
# }

# resource "helm_release" "nginx" {
#   name             = "nginx-ingress"
#   namespace        = "core"
#   create_namespace = true
#   repository       = "https://helm.nginx.com/stable" #"https://prometheus-community.github.io/helm-charts"
#   chart            = "nginx-ingress"                 #"kube-prometheus-stack"

#   timeout         = 900
#   cleanup_on_fail = true
#   atomic          = true

#   depends_on = [
#     google_container_cluster.cluster,
#     google_container_node_pool.pool,
#   ]
# }
