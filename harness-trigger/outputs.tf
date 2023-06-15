output "verbose" {
  value = { for key, details in local.trg_by_svc : key => details }
}
output "verbose-infra" {
  value = { for key, details in local.trg_by_infra : key => details }
}
output "trigger" {
  value = { for key, details in harness_platform_triggers.trigger : key => {
    identifier   = details.identifier
    org_id       = details.org_id
    project_id   = details.project_id
    test         = "${local.trg_by_infra[key].svc}_${inpt}_${local.trg_by_infra[key].env}"
    inputset_ids = local.trg_by_infra[key].TRIGGER_INPUTSET
  } }
}
