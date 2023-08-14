terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
  }
  subscription_id = "c418521d-a711-413b-afde-943205b4c335"
  client_id = "699afc91-2e6a-4b50-b808-42592db23582"
  client_secret = "PLN8Q~kMXKEXDp-9.i.ssqpUgLRrrrP7sRIL3bZ8"
  tenant_id = "64107c66-350c-45a9-94e5-dcfb6502b776"
}
