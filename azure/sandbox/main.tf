resource "azurerm_resource_group" "core" {
  name     = "pwolthausen-test-cac"
  location = "Canada Central"
  tags = {
    owner = "pwolthausen@cloudops.com"
    role  = "app"
    env   = "test"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "pwolthausen-hub"
  location = "Canada Central"
  tags = {
    owner = "pwolthausen@cloudops.com"
    role  = "vpn"
    env   = "test"
  }
}

resource "azurerm_ssh_public_key" "core" {
  name                = "pw-ssh"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  public_key          = file("~/.ssh/pwolthausen.pub")
}
