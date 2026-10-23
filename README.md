# terraform-google-service-account

Service account with project roles, optional GKE Workload Identity binding and impersonation grants; keys forbidden in prod

## Opinions

- Exactly one service account per module instance; the account id is `name` (6 to 30 characters), so two instances never collide.
- Project roles are granted additively (`google_project_iam_member`), never authoritatively.
- Workload Identity (`roles/iam.workloadIdentityUser`) and impersonation (`roles/iam.serviceAccountTokenCreator`) are granted on the service account itself, not the project.
- Keys are a last resort: `create_key` is off by default and rejected when `context.environment` is `prod`. A created key lives in state and is exposed only through the sensitive `key` output.
- Service accounts have no labels. `labels` is kept for interface consistency and is only exposed through the `labels` output.
- `context.extra_tags` keys and values are normalised to valid GCP label syntax (lowercase, `[^a-z0-9_-]` → `-`, 63 chars); `labels` are applied verbatim and win.

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "this" {
  source = "git::https://github.com/Olensys/terraform-google-service-account.git?ref=v1.1.0"

  name       = module.naming.name
  project_id = "my-project"
  context = var.context

  project_roles = ["roles/logging.logWriter"]
  labels  = module.naming.labels
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-google-modules/service-accounts/google | 5.1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_service_account_iam_member.impersonator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Service account id. 6 to 30 characters: lowercase letters, digits and hyphens, starting with a letter and not ending with a hyphen. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project that owns the service account. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_create_key"></a> [create\_key](#input\_create\_key) | Create a service account key. A last resort: forbidden when context.environment is prod. The key is stored in state. | `bool` | `false` | no |
| <a name="input_impersonators"></a> [impersonators](#input\_impersonators) | IAM members (for example user:a@example.com or serviceAccount:x@p.iam.gserviceaccount.com) granted roles/iam.serviceAccountTokenCreator on this service account. | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Kept for interface consistency. Service accounts do not support labels; the merged map is only exposed through the labels output. | `map(string)` | `{}` | no |
| <a name="input_project_roles"></a> [project\_roles](#input\_project\_roles) | Project-level roles granted to the service account in project\_id, for example roles/storage.objectViewer. | `list(string)` | `[]` | no |
| <a name="input_workload_identity"></a> [workload\_identity](#input\_workload\_identity) | GKE Workload Identity binding: the Kubernetes service account allowed to act as this service account. Null disables the binding. | <pre>object({<br/>    namespace                  = string<br/>    kubernetes_service_account = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_email"></a> [email](#output\_email) | Email address of the service account. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified ID of the service account. Null when create is false. |
| <a name="output_key"></a> [key](#output\_key) | Decoded private key JSON when create\_key is true, otherwise null. Sensitive; keys are a last resort. |
| <a name="output_labels"></a> [labels](#output\_labels) | Merged labels map for the interface contract (service accounts do not carry labels). Null when create is false. |
| <a name="output_member"></a> [member](#output\_member) | IAM member string, serviceAccount:<email>. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Account id of the service account (the part before the @). Null when create is false. |
| <a name="output_project_role_bindings"></a> [project\_role\_bindings](#output\_project\_role\_bindings) | The <project>=><role> elements passed to the upstream module. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Resource name of the service account, projects/<project>/serviceAccounts/<email>. Null when create is false. |
<!-- END_TF_DOCS -->
