provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kokatic_r" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_postgresql_flexible_server" "kokatic_postgresql_server" {
  name                   = "kokatic_pg_geo"
  resource_group_name    = azurerm_resource_group.kokatic_r.name
  location               = azurerm_resource_group.kokatic_r.location
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

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "kokaticstorageacc1234"
  resource_group_name      = azurerm_resource_group.kokatic_r.name
  location                 = azurerm_resource_group.kokatic_r.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "my_app_service_plan" {
  name                = "my-app-service-plan"
  location            = azurerm_resource_group.kokatic_r.location
  resource_group_name = azurerm_resource_group.kokatic_r.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "kokaticsapp" {
  name                       = "kokaticapp"
  location                   = azurerm_resource_group.kokatic_r.location
  resource_group_name        = azurerm_resource_group.kokatic_r.name
  app_service_plan_id        = azurerm_app_service_plan.my_app_service_plan.id
  storage_account_name       = azurerm_storage_account.my_storage_account.name
  storage_account_access_key = azurerm_storage_account.my_storage_account.primary_access_key
  os_type                    = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}