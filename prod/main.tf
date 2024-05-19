provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kokatic_rg" {
  name     = "kokatic_rg"
  location = "East US"
}

resource "azurerm_postgresql_flexible_server" "kokatic_bdd" {
  name                   = "kokaticbddazd"
  resource_group_name    = azurerm_resource_group.kokatic_rg.name
  location               = azurerm_resource_group.kokatic_rg.location
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

resource "azurerm_storage_account" "kokaticstorageaccbdd" {
  name                     = "kokaticstorageaccbdd"
  resource_group_name      = azurerm_resource_group.kokatic_rg.name
  location                 = azurerm_resource_group.kokatic_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "kokatic_app_service_plan" {
  name                = "kokatic-app-service-plan"
  location            = azurerm_resource_group.kokatic_rg.location
  resource_group_name = azurerm_resource_group.kokatic_rg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "kokaticsapp" {
  name                       = "kokaticapp"
  location                   = azurerm_resource_group.kokatic_rg.location
  resource_group_name        = azurerm_resource_group.kokatic_rg.name
  app_service_plan_id        = azurerm_app_service_plan.kokatic_app_service_plan.id
  storage_account_name       = azurerm_storage_account.my_storage_account.name
  storage_account_access_key = azurerm_storage_account.my_storage_account.primary_access_key
  os_type                    = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}
