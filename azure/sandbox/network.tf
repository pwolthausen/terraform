###################################################
##### hub network
###################################################

resource "azurerm_virtual_network" "hub" {
  name                = "vpc-pw-hub"
  address_space       = ["192.168.100.0/24"]
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    usage       = "hub-vpc"
  }
}

resource "azurerm_subnet" "hub_infra_test" {
  name                 = "sb-pw-hub-infra"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["192.168.100.32/27"]
}

###########################
##### Bastion
###########################

# resource "azurerm_subnet" "bastion" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.hub.name
#   virtual_network_name = azurerm_virtual_network.hub.name
#   address_prefixes     = ["192.168.1.0/27"]
# }
#
# resource "azurerm_public_ip" "bastion" {
#   name                = "pw-bastion-ip"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#   }
# }
#
# resource "azurerm_bastion_host" "bastion" {
#   name                = "pw-bastion"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   sku                 = "Standard"
#
#   file_copy_enabled = true
#   tunneling_enabled = true
#
#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.bastion.id
#     public_ip_address_id = azurerm_public_ip.bastion.id
#   }
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#     role        = "bastion"
#   }
# }

###################################################
##### core network
###################################################

resource "azurerm_virtual_network" "core" {
  name                = "vpc-pw-cac"
  address_space       = ["192.168.101.0/24"]
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    usage       = "primary-vpc"
  }
}

resource "azurerm_subnet" "core_infra" {
  name                 = "sb-pw-cac-core"
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["192.168.101.0/25"]
}

# resource "azurerm_subnet" "aks_pods" {
#   name                 = "sb-pw-cac-core-pods"
#   resource_group_name  = azurerm_resource_group.core.name
#   virtual_network_name = azurerm_virtual_network.core.name
#   address_prefixes     = ["10.64.0.0/16"]
# }

resource "azurerm_virtual_network_peering" "core_hub_peer" {
  name                      = "pw-core-hub"
  resource_group_name       = azurerm_resource_group.core.name
  virtual_network_name      = azurerm_virtual_network.core.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub_core_peer" {
  name                      = "pw-hub-core"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.core.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}
