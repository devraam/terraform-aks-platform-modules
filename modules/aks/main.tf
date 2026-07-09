# Reusable AKS module: cluster + system node pool + Workload Identity + ACR pull.
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100"
    }
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version

  # Passwordless workload authentication (Entra ID / Azure AD Workload Identity)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  role_based_access_control_enabled = true

  default_node_pool {
    name                 = "system"
    node_count           = var.node_count
    vm_size              = var.node_vm_size
    auto_scaling_enabled = true
    min_count            = var.node_count
    max_count            = var.node_max_count
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Least-privilege image pulls: AcrPull only, no admin credentials anywhere.
resource "azurerm_role_assignment" "acr_pull" {
  count                            = var.acr_id == null ? 0 : 1
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
