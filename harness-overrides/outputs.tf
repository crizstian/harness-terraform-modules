output "overrides" {
  value = { for key, details in harness_platform_environment_service_overrides.overrides : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
    }
  }
}
