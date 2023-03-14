output "organization" {
  value = { for key, details in harness_platform_organization.org : key =>
    {
      org_id          = details.identifier
      seed_project_id = harness_platform_project.seed_org_project[key].identifier
      suffix          = var.suffix
    }
  }
}

output "project" {
  value = { for key, details in harness_platform_project.project : key =>
    {
      project_id = details.identifier
      org_id     = details.org_id
    }
  }
}
