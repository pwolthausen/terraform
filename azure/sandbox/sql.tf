# resource "azurerm_mysql_server" "webapp" {
#   name                = "pw-webapp-sql"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#
#   administrator_login          = "pwolthausen"
#   administrator_login_password = "H@Sh1CoR3!"
#
#   sku_name   = "B_Gen5_2"
#   storage_mb = 5120
#   version    = "5.7"
#
#   auto_grow_enabled                 = true
#   backup_retention_days             = 7
#   geo_redundant_backup_enabled      = false
#   infrastructure_encryption_enabled = false
#   public_network_access_enabled     = false
#   ssl_enforcement_enabled           = true
# }
