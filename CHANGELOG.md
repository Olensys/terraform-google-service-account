# Changelog

## [1.1.1](https://github.com/Olensys/terraform-google-service-account/compare/v1.1.0...v1.1.1) (2026-10-24)


### Bug Fixes

* **examples:** pin naming module to v1.0.1 ([ab70691](https://github.com/Olensys/terraform-google-service-account/commit/ab706910eaa0da78983ff5fc4c429e3cbcbbca20))
* run integration on change and weekly instead of nightly ([fbf30c5](https://github.com/Olensys/terraform-google-service-account/commit/fbf30c52b1d038eb1bb1ddcc7501177b3028976d))

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, `[^a-z0-9_-]` replaced by `-`, 63 characters); `labels` are applied verbatim and win

### Tests

- `test_tags_contract` now covers mixed-case extra tags and verifies normalisation

### Docs

- Usage shows the naming module; Opinions describe label normalisation

### Behaviour changes

- `labels` output and applied labels now contain normalised keys and values for `context.extra_tags` (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on mixed-case or space-containing extra tags must expect the normalised form; values passed in `labels` are unchanged.

## 1.0.0

- Service account with project roles, optional GKE Workload Identity binding, impersonation grants and a sensitive key output (forbidden in prod).
