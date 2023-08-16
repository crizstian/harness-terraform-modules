output "environment" {
  value = { for key, details in harness_platform_environment.environment : key =>
    {
      identifier             = details.identifier
      org_id                 = details.org_id
      project_id             = details.project_id
      type                   = details.type
      primary_artifact       = try(var.harness_platform_environments[key].primary_artifact, "")
      trigger_artifact_regex = try(var.harness_platform_environments[key].trigger_artifact_regex, "")
    }
  }
}
output "infrastructure" {
  value = { for key, details in harness_platform_infrastructure.infrastructure : key =>
    {
      identifier         = details.identifier
      org_id             = details.org_id
      project_id         = details.project_id
      env_id             = details.env_id
      delegate_selectors = local.infrastructures[key].vars.delegate_selectors
    }
  }
}
