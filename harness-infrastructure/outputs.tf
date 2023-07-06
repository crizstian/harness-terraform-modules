output "environment" {
  value = { for key, details in harness_platform_environment.environment : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
      type       = details.type
    }
  }
}
output "infrastructure" {
  value = { for key, details in harness_platform_infrastructure.infrastructure : key =>
    {
      identifier         = details.identifier
      org_id             = details.org_id
      project_id         = details.project_id
      delegate_selectors = local.infrastructures[key].vars.delegate_selectors
    }
  }
}
