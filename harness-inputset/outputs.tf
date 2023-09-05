output "inputset" {
  value = { for key, details in harness_platform_input_set.inputset : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
    }
  }
}
output "verbose" {
  value = { for key, details in local.inpt_by_svc : key => details }
}
output "verbose_by_infra" {
  value = { for key, details in local.inpt_by_infra : key => details }
}
