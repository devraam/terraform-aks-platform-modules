variable "name" {
  description = "Base name for the cluster (environment-qualified, e.g. platform-dev)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group hosting the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version (pin explicitly; upgrades are reviewed PRs)."
  type        = string
}

variable "node_count" {
  description = "Baseline (and autoscaler minimum) node count for the system pool."
  type        = number
  default     = 2
}

variable "node_max_count" {
  description = "Autoscaler maximum node count for the system pool."
  type        = number
  default     = 5
}

variable "node_vm_size" {
  description = "VM size for system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "acr_id" {
  description = "Optional ACR resource ID to grant AcrPull to the kubelet identity."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources (audit/cost traceability)."
  type        = map(string)
  default     = {}
}
