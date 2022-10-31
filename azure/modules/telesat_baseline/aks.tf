# resource "azurerm_resource_group" "webapp" {
#   name     = "rg-pw-webapp-test-cac"
#   location = var.location
#   tags = {
#     owner = "pwolthausen@cloudops.com"
#     role  = "webapp"
#     env   = "test"
#   }
# }
#
# resource "azurerm_kubernetes_cluster" "exfo_test" {
#   name                = "aks-pw-webapp-test-cac-01"
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name
#   dns_prefix          = "pw-webapp-test-cac"
#   node_resource_group = "rg-pw-cac-aks-node-pool"
#
#   default_node_pool {
#     name           = "default"
#     node_count     = 1
#     vm_size        = "Standard_D2_v2"
#     vnet_subnet_id = azurerm_subnet.spokes["public"].id
#     pod_subnet_id  = azurerm_subnet.spokes["akspod"].id
#   }
#
#   network_profile {
#     network_plugin = "azure"
#     network_mod    = "transparent"
#     outbound_type  = "userDefinedRouting"
#     # pod_cidr           = "10.64.0.0/16"
#     service_cidr       = "10.65.0.0/22"
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
# resource "azurerm_kubernetes_cluster_node_pool" "example" {
#   name                  = "webapp"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.exfo_test.id
#   vm_size               = "Standard_DS2_v2"
#   node_count            = 2
#   # pod_subnet_id         = module.app1_network.subnet_id.sb-pw-aks-cac-01-akspods
#
#   tags = {
#     Environment = "Production"
#   }
# }
