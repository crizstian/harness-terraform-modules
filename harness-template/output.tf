locals {
  template_output = { for key, details in harness_platform_template.template : key =>
    {
      identifier = details.identifier
    }
  }
}

output "templates" {
  value = local.template_output
}
