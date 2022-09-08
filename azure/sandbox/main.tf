resource "azurerm_resource_group" "main" {
  name     = "pwolthausen-cac"
  location = "Canada Central"
}

resource "azurerm_ssh_public_key" "main" {
  name                = "pw-ssh"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_key          = file("~/.ssh/pwolthausen.pub")
}
