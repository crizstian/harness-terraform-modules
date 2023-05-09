output "services" {
  value = { for key, details in harness_platform_service.services : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
    }
  }
}
