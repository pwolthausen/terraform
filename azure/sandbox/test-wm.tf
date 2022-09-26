# resource "azurerm_network_interface" "test_infra" {
#   name                = "pw-test-infra-nic"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#
#   ip_configuration {
#     name                          = "test-infra-internal-ip"
#     subnet_id                     = azurerm_subnet.hub_infra_test.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
#
# resource "azurerm_virtual_machine" "test_infra" {
#   name                  = "vm-pw-test-01"
#   location              = azurerm_resource_group.hub.location
#   resource_group_name   = azurerm_resource_group.hub.name
#   network_interface_ids = [azurerm_network_interface.test_infra.id]
#   vm_size               = "Standard_D2s_v3"
#
#   delete_os_disk_on_termination    = true
#   delete_data_disks_on_termination = true
#
#   storage_image_reference {
#     publisher = "debian"
#     offer     = "debian-11"
#     sku       = "11-gen2"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "pw-test-os-disk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#     disk_size_gb      = 30
#   }
#   os_profile {
#     computer_name  = "pw-test-01"
#     admin_username = var.os_admin
#     custom_data = templatefile("cloud-init.tpl", {
#       public_key = azurerm_ssh_public_key.core.public_key
#     })
#   }
#
#   os_profile_linux_config {
#     disable_password_authentication = true
#     ssh_keys {
#       key_data = azurerm_ssh_public_key.core.public_key
#       path     = "/home/${var.os_admin}/.ssh/authorized_keys"
#     }
#   }
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#     usage       = "test-infra"
#   }
# }
#
# resource "azurerm_managed_disk" "test_infra_data" {
#   name                 = "pw-test-infra-data"
#   location             = azurerm_resource_group.hub.location
#   resource_group_name  = azurerm_resource_group.hub.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "128"
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#     usage       = "test-infra"
#   }
# }
# resource "azurerm_virtual_machine_data_disk_attachment" "test_infra_data" {
#   managed_disk_id    = azurerm_managed_disk.test_infra_data.id
#   virtual_machine_id = azurerm_virtual_machine.test_infra.id
#   lun                = "10"
#   caching            = "ReadWrite"
# }
#
# #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# #LoadBalancer
# resource "azurerm_public_ip" "test_infra_lb_ip" {
#   name                = "pw-test-infra-lb-ip"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#     usage       = "test-infra-lb"
#   }
# }
#
# # resource "azurerm_lb" "test_infra" {
# #   name                = "pw-test_infra-lb"
# #   location            = azurerm_resource_group.hub.location
# #   resource_group_name = azurerm_resource_group.hub.name
# #
# #   frontend_ip_configuration {
# #     name                 = "PublicIPAddress"
# #     public_ip_address_id = azurerm_public_ip.test_infra_lb_ip.id
# #   }
# # }
