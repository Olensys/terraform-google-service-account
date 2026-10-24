terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0, < 8.0" }
  }
}

variable "project_id" {
  description = "GCP project that will own the service account."
  type        = string
}

locals {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "sa"
    owner        = "platform"
    cost_center  = "eng"
  }
}

module "naming" {
  source = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"

  context = local.context
}

module "this" {
  source = "../../"

  name       = "olensys-test-sa"
  context    = local.context
  project_id = var.project_id
  labels     = module.naming.labels

  project_roles = ["roles/logging.logWriter"]
}

output "email" {
  description = "Email of the example service account."
  value       = module.this.email
}

output "member" {
  description = "IAM member string of the example service account."
  value       = module.this.member
}
