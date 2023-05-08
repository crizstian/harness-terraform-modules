output "environment" {
  value = { for key, details in harness_platform_environment.environment : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
    }
  }
}
output "infrastructure" {
  value = { for key, details in harness_platform_infrastructure.infrastructure : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
    }
  }
}
