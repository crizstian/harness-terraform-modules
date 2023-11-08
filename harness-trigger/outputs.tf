output "verbose" {
  value = { for key, details in local.trg_by_svc : key => details }
}
output "verbose-infra" {
  value = { for key, details in local.trg_by_infra : key => details }
}
output "trigger" {
  value = { for key, details in harness_platform_triggers.trigger : key => {
    identifier  = details.identifier
    org_id      = details.org_id
    project_id  = details.project_id
    pipeline_id = details.target_id
    service_id  = try(local.triggers[key].vars["${local.triggers[key].vars.service_type}_service_id"], "NONE")
    name        = details.name
  } }
}
