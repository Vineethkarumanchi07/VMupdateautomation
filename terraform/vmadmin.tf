resource "azurerm_resource_group" "Vm-resources" {
  name     = "VM-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "Vm-virtual_network" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Vm-resources.location
  resource_group_name = azurerm_resource_group.Vm-resources.name
}

resource "azurerm_subnet" "Vm-resources-subnet" {
  name                 = "acctsub"
  resource_group_name  = azurerm_resource_group.Vm-resources.name
  virtual_network_name = azurerm_virtual_network.Vm-virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "Vm-network-interface" {
  name                = "acctni"
  location            = azurerm_resource_group.Vm-resources.location
  resource_group_name = azurerm_resource_group.Vm-resources.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.Vm-resources-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "terra-app-frontend" {
  name                = "Demo-machine"
  resource_group_name = azurerm_resource_group.Vm-resources.name
  location            = azurerm_resource_group.Vm-resources.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Helloworld@123"
  network_interface_ids = [
    azurerm_network_interface.Vm-network-interface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "terra-app-frontend" {
  count = 2
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.terra-app-frontend.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.27"
  auto_upgrade_minor_version = true

  settings = jsonencode(
  {
   GCS_AUTO_CONFIG = true,
   workspaceId = azurerm_log_analytics_workspace.terra-autoAcc.workspace_id
  }
  )
  protected_settings = jsonencode(
  {
   workspaceKey = azurerm_log_analytics_workspace.terra-autoAcc.primary_shared_key
  }
  )
}

# resource "azurerm_virtual_network" "example" {
#   name                = "examplevnet"
#   address_space       = ["192.168.1.0/24"]
#   location            = azurerm_resource_group.Vm-resources.location
#   resource_group_name = azurerm_resource_group.Vm-resources.name
# }

# resource "azurerm_subnet" "example" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name = azurerm_resource_group.Vm-resources.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["192.168.1.224/27"]
# }

# resource "azurerm_public_ip" "example" {
#   name                = "examplepip"
#   location            = azurerm_resource_group.Vm-resources.location
#   resource_group_name = azurerm_resource_group.Vm-resources.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_bastion_host" "example" {
#   name                = "examplebastion"
#   location            = azurerm_resource_group.Vm-resources.location
#   resource_group_name = azurerm_resource_group.Vm-resources.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.example.id
#     public_ip_address_id = azurerm_public_ip.example.id
#   }
# }