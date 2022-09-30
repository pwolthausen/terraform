# resource "azurerm_network_security_group" "webapp" {
#   name                = "sg-pw-cac-webapp"
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#   }
# }
#
# resource "azurerm_network_security_rule" "deny_all_ingress" {
#   name                        = "deny-all-ingress"
#   priority                    = 4096
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_address_prefix       = "*"
#   source_port_range           = "*"
#   destination_address_prefix  = "*"
#   destination_port_range      = "*"
#   resource_group_name         = azurerm_resource_group.webapp.name
#   network_security_group_name = azurerm_network_security_group.webapp.name
# }
#
# resource "azurerm_network_security_rule" "allow_all_egress" {
#   name                        = "allow-all-egress"
#   priority                    = 4095
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_address_prefix       = "*"
#   source_port_range           = "*"
#   destination_address_prefix  = "*"
#   destination_port_range      = "*"
#   resource_group_name         = azurerm_resource_group.webapp.name
#   network_security_group_name = azurerm_network_security_group.webapp.name
# }
#
# resource "azurerm_network_security_rule" "allow_ssh" {
#   name                        = "allow-ssh"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   destination_address_prefix  = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "173.178.40.19/32"
#   source_port_range           = "22"
#   resource_group_name         = azurerm_resource_group.webapp.name
#   network_security_group_name = azurerm_network_security_group.webapp.name
# }
#
# resource "azurerm_network_security_rule" "allow_bastion" {
#   name                         = "allow-all-bastion"
#   priority                     = 101
#   direction                    = "Inbound"
#   access                       = "Allow"
#   protocol                     = "*"
#   destination_address_prefixes = azurerm_subnet.webapp.address_prefixes
#   destination_port_range       = "*"
#   source_address_prefixes      = azurerm_subnet.bastion.address_prefixes
#   source_port_range            = "*"
#   resource_group_name          = azurerm_resource_group.webapp.name
#   network_security_group_name  = azurerm_network_security_group.webapp.name
# }
