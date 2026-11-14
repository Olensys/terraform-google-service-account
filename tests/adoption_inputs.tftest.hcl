# Pass-through inputs that let a caller import an existing service account
# without a live change. Every default reproduces the previous hard-coded value.
mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      name  = "projects/example-project/serviceAccounts/example-sa@example-project.iam.gserviceaccount.com"
      email = "example-sa@example-project.iam.gserviceaccount.com"
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example-sa"
  project_id = "example-project"
}

run "test_defaults_match_previous_literals" {
  command = plan

  assert {
    condition     = module.this[0].service_accounts_map["example-sa"].display_name == "example-sa"
    error_message = "display name must default to name."
  }

  assert {
    condition     = module.this[0].service_accounts_map["example-sa"].description == "example test service account managed by Terraform"
    error_message = "description must default to the context-derived sentence."
  }
}

run "test_display_name_override" {
  command = plan

  variables {
    display_name = "Example deployer"
  }

  assert {
    condition     = module.this[0].service_accounts_map["example-sa"].display_name == "Example deployer"
    error_message = "display_name must be passed through."
  }
}

run "test_description_override" {
  command = plan

  variables {
    description = "Deploys the example application"
  }

  assert {
    condition     = module.this[0].service_accounts_map["example-sa"].description == "Deploys the example application"
    error_message = "description must be passed through."
  }
}

run "test_description_empty_string_allowed" {
  command = plan

  variables {
    description = ""
  }

  assert {
    condition     = module.this[0].service_accounts_map["example-sa"].description == ""
    error_message = "an empty description must be passed through as no description."
  }
}

run "test_display_name_length_validation" {
  command = plan

  variables {
    display_name = join("", [for i in range(101) : "a"])
  }

  expect_failures = [var.display_name]
}
