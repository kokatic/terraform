provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "devkokaticrg" {
  name     = "devkokatic_rg"
  location = "East US"
}

resource "azurerm_postgresql_flexible_server" "devkokaticbdd" {
  name                   = "devkokaticbdd"
  resource_group_name    = azurerm_resource_group.devkokaticrg.name
  location               = azurerm_resource_group.devkokaticrg.location
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  version                = "12"

  sku_name = "B_Standard_B1ms"
  storage_mb = 32768

  zone = "1"

  maintenance_window {
    day_of_week  = 6
    start_hour   = 3
    start_minute = 0
  }
}

resource "azurerm_storage_account" "devkokaticstoragebdd" {
  name                     = "devkokaticstoragebdd"
  resource_group_name      = azurerm_resource_group.devkokaticrg.name
  location                 = azurerm_resource_group.devkokaticrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "devkokaticapp" {
  name                = "devkokaticapp"
  location            = azurerm_resource_group.devkokaticrg.location
  resource_group_name = azurerm_resource_group.devkokaticrg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "devkokaticsapp" {
  name                       = "devkokaticapp"
  location                   = azurerm_resource_group.devkokaticrg.location
  resource_group_name        = azurerm_resource_group.devkokaticrg.name
  app_service_plan_id        = azurerm_app_service_plan.devkokaticapp.id
  storage_account_name       = azurerm_storage_account.devkokaticstoragebdd.name
  storage_account_access_key = azurerm_storage_account.devkokaticstoragebdd.primary_access_key
  os_type                    = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }

  site_config {
    linux_fx_version = "Python|3.9"
  }
}
