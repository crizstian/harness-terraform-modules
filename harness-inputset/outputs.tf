output "inputset" {
  value = { for key, details in harness_platform_input_set.inputset : key =>
    {
      identifier = details.identifier
      org_id     = details.org_id
      project_id = details.project_id
      name       = details.name
    }
  }
}
output "verbose" {
  value = { for key, details in local.inpt_by_svc : key => details }
}
output "verbose_by_infra" {
  value = { for key, details in local.inpt_by_infra : key => details }
}

output "inpt_by_all_infra" {
  value = { for key, details in local.inpt_by_all_infra : key => details }
}
output "inpt_by_base_env" {
  value = { for key, details in local.inpt_by_base_env : key => details }
}
