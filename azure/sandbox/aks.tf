# resource "azurerm_kubernetes_cluster" "exfo_test" {
#   name                = "pw-exfo-test"
#   location            = azurerm_resource_group.core.location
#   resource_group_name = azurerm_resource_group.core.name
#   dns_prefix          = "pwtest"
#
#   default_node_pool {
#     name           = "default"
#     node_count     = 2
#     vm_size        = "Standard_D2_v2"
#     vnet_subnet_id = azurerm_subnet.core_infra.id
#   }
#
#   network_profile {
#     network_plugin     = "kubenet"
#     service_cidr       = "10.65.0.0/16"
#     pod_cidr           = "10.64.0.0/16"
#     docker_bridge_cidr = "172.17.0.1/16"
#     dns_service_ip     = "10.65.56.56"
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   tags = {
#     Environment = "Production"
#   }
# }
#
# output "aks_config" {
#   value     = azurerm_kubernetes_cluster.exfo_test.kube_config_raw
#   sensitive = true
# }
#
# output "aks_host" {
#   value     = azurerm_kubernetes_cluster.exfo_test.kube_config[0].host
#   sensitive = true
# }
#
# data "azurerm_kubernetes_cluster" "exfo_test" {
#   name                = azurerm_kubernetes_cluster.exfo_test.name
#   resource_group_name = azurerm_resource_group.core.name
# }
#
# provider "kubernetes" {
#   host                   = data.azurerm_kubernetes_cluster.exfo_test.kube_config.0.host
#   client_certificate     = base64decode(data.azurerm_kubernetes_cluster.exfo_test.kube_config.0.client_certificate)
#   client_key             = base64decode(data.azurerm_kubernetes_cluster.exfo_test.kube_config.0.client_key)
#   cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.exfo_test.kube_config.0.cluster_ca_certificate)
# }
#
# resource "kubernetes_namespace" "webapp" {
#   metadata {
#     annotations = {
#       name = "webapp"
#     }
#     labels = {
#       app = "web"
#     }
#     name = "webapp"
#   }
#   depends_on = [
#     azurerm_kubernetes_cluster.exfo_test
#   ]
# }
#
# resource "kubernetes_deployment" "example" {
#   metadata {
#     name      = "test-web-app"
#     namespace = kubernetes_namespace.webapp.metadata[0].name
#     labels = {
#       app = "webapp"
#     }
#   }
#
#   spec {
#     replicas = 3
#
#     selector {
#       match_labels = {
#         app = "webapp"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "webapp"
#         }
#       }
#
#       spec {
#         container {
#           image = "nginx:1.21.6"
#           name  = "webapp"
#
#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#
#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80
#
#               http_header {
#                 name  = "X-Custom-Header"
#                 value = "Awesome"
#               }
#             }
#
#             initial_delay_seconds = 3
#             period_seconds        = 3
#           }
#         }
#       }
#     }
#   }
#   depends_on = [
#     azurerm_kubernetes_cluster.exfo_test
#   ]
# }
#
# resource "kubernetes_service" "webapp" {
#   metadata {
#     name      = "webapp"
#     namespace = kubernetes_namespace.webapp.metadata[0].name
#   }
#   spec {
#     selector = {
#       app = "webapp"
#     }
#     session_affinity = "ClientIP"
#     port {
#       node_port   = 30200
#       port        = 80
#       target_port = 80
#     }
#
#     type = "NodePort"
#   }
#   depends_on = [
#     azurerm_kubernetes_cluster.exfo_test
#   ]
# }
