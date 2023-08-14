# Create a resource group
resource "azurerm_resource_group" "terraform-acc" {
  name     = "Poc-update-management-center"
  location = "East US"
}

# Create log analytics workspace
resource "azurerm_log_analytics_workspace" "terra-autoAcc" {
  name                = "Updated-logs"
  location            = azurerm_resource_group.terraform-acc.location
  resource_group_name = azurerm_resource_group.terraform-acc.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create a log analytics workspace (enable the log analytics space to be holding the updates)
resource "azurerm_log_analytics_solution" "terra-autoAcc" {
  solution_name         = "Updates"
  location              = azurerm_log_analytics_workspace.terra-autoAcc.location
  resource_group_name   = azurerm_resource_group.terraform-acc.name
  workspace_resource_id = azurerm_log_analytics_workspace.terra-autoAcc.id
  workspace_name        = azurerm_log_analytics_workspace.terra-autoAcc.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# Create a azurerm_log_analytics_linked_service(ensure link log analytics to automation account)
resource "azurerm_log_analytics_linked_service" "terra-autoAcc" {
  resource_group_name = azurerm_resource_group.terraform-acc.name
  workspace_id        = azurerm_log_analytics_workspace.terra-autoAcc.id
  read_access_id      = azurerm_automation_account.terra-autoAcc.id
  
  depends_on = [azurerm_log_analytics_solution.terra-autoAcc]
}