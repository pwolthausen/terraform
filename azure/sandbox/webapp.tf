resource "azurerm_resource_group" "webapp" {
  name     = "pw-cac-webapp"
  location = var.location
  tags = {
    owner = "pwolthausen@cloudops.com"
    role  = "webapp"
    env   = "test"
  }
}

output "webapp_ip" {
  value = azurerm_network_interface.webapp.private_ip_address
}

resource "azurerm_public_ip" "webapp" {
  name                = "ip-pw-cac-webapp"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "webapp" {
  name                = "pw-web-nic"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name

  ip_configuration {
    name                          = "web-internal-ip"
    subnet_id                     = module.app1_network.subnet_id["sb-pw-cac-test-app-webapp"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webapp.id
  }
}

resource "azurerm_virtual_machine" "webapp" {
  name                  = "vm-pw-webhost-01"
  location              = azurerm_resource_group.webapp.location
  resource_group_name   = azurerm_resource_group.webapp.name
  network_interface_ids = [azurerm_network_interface.webapp.id]
  vm_size               = "Standard_D2s_v3"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pw-webhost-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 30
  }
  os_profile {
    computer_name  = "pw-webhost-01"
    admin_username = var.os_admin
    custom_data = templatefile("cloud-init.tpl", {
      public_key = file("~/.ssh/pwolthausen.pub")
    })
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/pwolthausen.pub")
      path     = "/home/${var.os_admin}/.ssh/authorized_keys"
    }
  }

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    usage       = "webapp"
  }
}

resource "azurerm_managed_disk" "webapp_data" {
  name                 = "pw-webapp-data"
  location             = azurerm_resource_group.webapp.location
  resource_group_name  = azurerm_resource_group.webapp.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "128"

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    usage       = "webapp"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "webapp_data" {
  managed_disk_id    = azurerm_managed_disk.webapp_data.id
  virtual_machine_id = azurerm_virtual_machine.webapp.id
  lun                = "10"
  caching            = "ReadWrite"
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#LoadBalancer
# resource "azurerm_public_ip" "webapp_lb_ip" {
#   name                = "pw-webapp-lb-ip"
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = {
#     owner       = "pwolthausen"
#     environment = "test"
#     usage       = "webapp-lb"
#   }
# }

# resource "azurerm_lb" "webapp" {
#   name                = "pw-webapp-lb"
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name
#
#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.webapp_lb_ip.id
#   }
# }
