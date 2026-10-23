# Run only by the nightly integration workflow, against real cloud credentials.
variables {
  project_id = "olensys-integration"
}

run "apply_minimal" {
  command = apply

  module {
    source = "./examples/minimal"
  }

  assert {
    condition     = endswith(output.email, ".iam.gserviceaccount.com")
    error_message = "The service account email must be a gserviceaccount.com address."
  }
}
