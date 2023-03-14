output "organization" {
  value = { for key, details in harness_platform_organization.org : key =>
    {
      identifier = details.identifier
      suffix     = var.suffix
    }
  }
}

output "project" {
  value = { for key, details in harness_platform_project.project : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
    }
  }
}
