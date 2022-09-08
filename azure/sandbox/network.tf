resource "azurerm_virtual_network" "main" {
  name                = "vpc-pw-cac"
  address_space       = ["192.168.56.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    usage       = "primary-vpc"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "sb-pw-cac-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.56.0/25"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.56.128/27"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "pw-bastion-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    owner       = "pwolthausen"
    environment = "test"
  }
}

resource "azurerm_bastion_host" "bastion" {
  name                = "pw-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  file_copy_enabled = true
  tunneling_enabled = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = {
    owner       = "pwolthausen"
    environment = "test"
    role        = "bastion"
  }
}
