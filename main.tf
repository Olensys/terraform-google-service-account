locals {
  extra_labels = { for k, v in var.context.extra_tags :
  substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63) }
  labels = merge(local.extra_labels, var.labels)

  # Upstream expects "<project>=><role>" elements.
  project_role_bindings = [for r in var.project_roles : "${var.project_id}=>${r}"]

  service_account = var.create ? module.this[0].service_account : null
}

module "this" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "5.1.0"

  count = var.create ? 1 : 0

  project_id    = var.project_id
  names         = [var.name]
  prefix        = ""
  display_name  = var.name
  description   = "${var.context.application} ${var.context.environment} service account managed by Terraform"
  project_roles = local.project_role_bindings
  generate_keys = var.create_key
}

resource "google_service_account_iam_member" "workload_identity" {
  count = var.create && var.workload_identity != null ? 1 : 0

  service_account_id = local.service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.workload_identity.namespace}/${var.workload_identity.kubernetes_service_account}]"
}

resource "google_service_account_iam_member" "impersonator" {
  for_each = var.create ? toset(var.impersonators) : toset([])

  service_account_id = local.service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
