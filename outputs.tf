output "id" {
  description = "Fully qualified ID of the service account. Null when create is false."
  value       = try(local.service_account.id, null)
}

output "name" {
  description = "Account id of the service account (the part before the @). Null when create is false."
  value       = var.create ? var.name : null
}

output "email" {
  description = "Email address of the service account. Null when create is false."
  value       = try(local.service_account.email, null)

  precondition {
    condition     = !var.create_key || var.context.environment != "prod"
    error_message = "create_key is forbidden when context.environment is prod."
  }
}

output "self_link" {
  description = "Resource name of the service account, projects/<project>/serviceAccounts/<email>. Null when create is false."
  value       = try(local.service_account.name, null)
}

output "member" {
  description = "IAM member string, serviceAccount:<email>. Null when create is false."
  value       = try("serviceAccount:${local.service_account.email}", null)
}

output "key" {
  description = "Decoded private key JSON when create_key is true, otherwise null. Sensitive; keys are a last resort."
  value       = var.create && var.create_key ? module.this[0].key : null
  sensitive   = true
}

output "labels" {
  description = "Merged labels map for the interface contract (service accounts do not carry labels). Null when create is false."
  value       = var.create ? local.labels : null
}

output "project_role_bindings" {
  description = "The <project>=><role> elements passed to the upstream module. Null when create is false."
  value       = var.create ? local.project_role_bindings : null
}
