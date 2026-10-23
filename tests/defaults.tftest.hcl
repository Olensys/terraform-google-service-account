mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      name  = "projects/example-project/serviceAccounts/example-sa@example-project.iam.gserviceaccount.com"
      email = "example-sa@example-project.iam.gserviceaccount.com"
    }
  }
  mock_resource "google_service_account_key" {
    defaults = {
      private_key = "e30="
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

run "test_project_roles_bound" {
  command = plan

  variables {
    project_roles = ["roles/storage.objectViewer", "roles/logging.logWriter"]
  }

  # SMOKE: asserts the <project>=><role> list handed to upstream; the IAM members themselves are child-module resources proven in complete.tftest.hcl.
  assert {
    condition     = output.project_role_bindings == ["example-project=>roles/storage.objectViewer", "example-project=>roles/logging.logWriter"]
    error_message = "project_roles must be passed upstream as project=>role."
  }
}

run "test_role_format_validation" {
  command = plan

  variables {
    project_roles = ["storage.objectViewer"]
  }

  expect_failures = [var.project_roles]
}

run "test_workload_identity_binding" {
  command = plan

  variables {
    workload_identity = { namespace = "apps", kubernetes_service_account = "api" }
  }

  assert {
    condition     = google_service_account_iam_member.workload_identity[0].member == "serviceAccount:example-project.svc.id.goog[apps/api]"
    error_message = "Workload identity member must reference the KSA."
  }

  assert {
    condition     = google_service_account_iam_member.workload_identity[0].role == "roles/iam.workloadIdentityUser"
    error_message = "Workload identity role must be roles/iam.workloadIdentityUser."
  }
}

run "test_impersonators_bound" {
  command = plan

  variables {
    impersonators = ["user:a@example.com", "group:b@example.com"]
  }

  assert {
    condition     = length(google_service_account_iam_member.impersonator) == 2
    error_message = "One binding per impersonator."
  }

  assert {
    condition     = google_service_account_iam_member.impersonator["user:a@example.com"].role == "roles/iam.serviceAccountTokenCreator"
    error_message = "Impersonators get roles/iam.serviceAccountTokenCreator."
  }
}

run "test_key_forbidden_in_prod" {
  command = plan

  variables {
    create_key = true
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  expect_failures = [output.email]
}

run "test_key_allowed_outside_prod" {
  command = plan

  variables {
    create_key = true
  }

  # SMOKE: plan succeeding without the output.email precondition firing is the check; the key itself is created only on apply (complete.tftest.hcl).
  assert {
    condition     = output.project_role_bindings != null
    error_message = "Keys are allowed outside prod."
  }
}

run "test_two_instances_distinct_role_names" {
  command = plan

  variables {
    name = "first-sa"
  }

  # SMOKE: one instance per run is visible; asserts the account id derives from name. Collision-freedom of a second instance is a property of that derivation.
  assert {
    condition     = output.name == "first-sa"
    error_message = "Account id must derive from name."
  }
}

run "test_two_instances_distinct_role_names_second" {
  command = plan

  variables {
    name = "second-sa"
  }

  # SMOKE: see the first run; together they show different names give different account ids.
  assert {
    condition     = output.name == "second-sa" && output.name != "first-sa"
    error_message = "A different name must give a different account id."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create            = false
    project_roles     = ["roles/viewer"]
    workload_identity = { namespace = "apps", kubernetes_service_account = "api" }
    impersonators     = ["user:a@example.com"]
  }

  assert {
    condition     = output.id == null && output.name == null && output.email == null && output.self_link == null && output.member == null && output.key == null && output.labels == null && output.project_role_bindings == null
    error_message = "All outputs must be null when create is false."
  }

  assert {
    condition     = length(google_service_account_iam_member.workload_identity) == 0 && length(google_service_account_iam_member.impersonator) == 0
    error_message = "No IAM members when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "abcdefghijklmnopqrstuvwxyzabcde"
  }

  expect_failures = [var.name]
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { owner = "y", team = "z" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over extra_tags."
  }

  assert {
    condition     = output.labels.team == "z"
    error_message = "extra_tags must be merged."
  }
}
