data "azurerm_virtual_network" "hub" {
  name                = "vpc-${var.prefix}-vwan-${var.region_code}"
  resource_group_name = "${var.prefix}-vwan-${var.region_code}"
}

resource "azurerm_resource_group" "shared" {
  name     = "${var.prefix}-shared-${var.region_code}"
  location = var.location
  tags = merge(var.global_tags, {
    env  = "shared"
    role = "shared-resources"
  })
}

resource "azurerm_ssh_public_key" "shared" {
  name                = "${var.prefix}-shared-${var.region_code}"
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
  public_key          = file("~/.ssh/pwolthausen.pub")

  tags = merge(var.global_tags, {
    env = "shared"
  })
}
