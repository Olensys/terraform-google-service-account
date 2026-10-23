variable "name" {
  description = "Service account id. 6 to 30 characters: lowercase letters, digits and hyphens, starting with a letter and not ending with a hyphen."
  type        = string
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{4,28}[a-z0-9])$", var.name))
    error_message = "name must match ^[a-z]([a-z0-9-]{4,28}[a-z0-9])$ (6 to 30 characters)."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "GCP project that owns the service account."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "project_roles" {
  description = "Project-level roles granted to the service account in project_id, for example roles/storage.objectViewer."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for r in var.project_roles : startswith(r, "roles/")])
    error_message = "Every entry in project_roles must start with roles/."
  }
}

variable "workload_identity" {
  description = "GKE Workload Identity binding: the Kubernetes service account allowed to act as this service account. Null disables the binding."
  type = object({
    namespace                  = string
    kubernetes_service_account = string
  })
  default = null
}

variable "impersonators" {
  description = "IAM members (for example user:a@example.com or serviceAccount:x@p.iam.gserviceaccount.com) granted roles/iam.serviceAccountTokenCreator on this service account."
  type        = list(string)
  default     = []
}

variable "create_key" {
  description = "Create a service account key. A last resort: forbidden when context.environment is prod. The key is stored in state."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Kept for interface consistency. Service accounts do not support labels; the merged map is only exposed through the labels output."
  type        = map(string)
  default     = {}
}
