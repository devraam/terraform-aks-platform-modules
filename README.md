# Terraform Modules — AKS Platform Foundations

Reusable, modular Terraform for provisioning **AKS platform foundations on Azure**: cluster, container registry integration, and **Azure AD Workload Identity** for passwordless workload authentication. Sanitized reference of module patterns I use to provision governed, audit-ready environments for enterprise clients (financial services, telecom).

## What this demonstrates

- **Modular design** — the `modules/aks` module is consumed by thin per-environment root modules (`examples/dev`), so dev/staging/prod differ only in variables, never in copied code.
- **Workload Identity over secrets** — the cluster enables OIDC issuer + Workload Identity, so pods authenticate to Azure (Key Vault, ACR, storage) via federated identity instead of stored credentials.
- **Governance by default** — RBAC-enabled cluster, ACR attach with least-privilege `AcrPull`, tags for cost/audit traceability, and remote state expected in Azure Storage with state locking.
- **Environment patterns** — one `tfvars`-driven root per environment, same module version pinned across all of them; upgrades are explicit PRs.

## Layout

```
modules/aks/     reusable AKS module (cluster, node pool, OIDC/WI, ACR pull)
examples/dev/    thin environment root consuming the module
```

## Usage

```hcl
module "aks" {
  source = "github.com/devraam/terraform-aks-platform-modules//modules/aks"

  name                = "platform-dev"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.platform.name
  kubernetes_version  = "1.29"
  node_count          = 2
  node_vm_size        = "Standard_D4s_v5"
  acr_id              = azurerm_container_registry.platform.id
  tags = {
    environment = "dev"
    managed-by  = "terraform"
  }
}
```

Remote state (recommended):

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateplatform"
    container_name       = "tfstate"
    key                  = "platform-dev.tfstate"
  }
}
```

## Notes

- Values here are sanitized examples; production deployments add private networking, Azure Policy add-on, and per-client naming/governance conventions.
- Pin module versions with `?ref=` tags in real consumption.

## Author

Alexander Abril — Senior DevOps Engineer / Platform Engineer
[linkedin.com/in/abrilalexander](https://www.linkedin.com/in/abrilalexander) · [github.com/devraam](https://github.com/devraam)
