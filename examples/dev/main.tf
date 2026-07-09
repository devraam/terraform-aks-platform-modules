# Thin environment root: DEV. Staging/prod differ only in variables.
terraform {
  required_version = ">= 1.6"
  # Remote state with locking (Azure Storage) — see repo README.
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "platform" {
  name     = "rg-platform-dev"
  location = "eastus2"
  tags     = local.tags
}

resource "azurerm_container_registry" "platform" {
  name                = "acrplatformdevexample"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "Standard"
  admin_enabled       = false   # no admin creds: pulls use AcrPull via managed identity
  tags                = local.tags
}

module "aks" {
  source = "../../modules/aks"

  name                = "platform-dev"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  kubernetes_version  = "1.29"
  node_count          = 2
  node_max_count      = 4
  acr_id              = azurerm_container_registry.platform.id
  tags                = local.tags
}

locals {
  tags = {
    environment = "dev"
    managed-by  = "terraform"
    owner       = "platform-engineering"
  }
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}
