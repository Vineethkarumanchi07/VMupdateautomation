# Create a resource group
resource "azurerm_resource_group" "Automation-acc" {
  name     = "Automation-Resources"
  location = "East US"
}

# Create a automation account
resource "azurerm_automation_account" "terra-autoAcc" {
  name                = "tracking-automation-acc"
  location            = azurerm_resource_group.Automation-acc.location
  resource_group_name = azurerm_resource_group.Automation-acc.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

