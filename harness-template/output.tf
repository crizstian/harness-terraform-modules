locals {
  template_output = { for key, details in harness_platform_template.template : key =>
    {
      identifier = details.project_id != "" ? details.identifier : details.org_id != "" ? "org.${details.identifier}" : "account.${details.identifier}"
    }
  }
}

output "templates" {
  value = local.template_output
}
