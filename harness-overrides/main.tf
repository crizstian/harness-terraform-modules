resource "harness_platform_environment_service_overrides" "overrides" {
  for_each   = local.service_overrides
  identifier = each.value.vars.identifier
  org_id     = each.value.vars.org_id
  env_id     = each.value.vars.env_id
  project_id = each.value.vars.project_id
  service_id = each.value.vars.service_id
  yaml       = can(each.value.vars.yaml) ? templatefile(each.value.vars.yaml, each.value.vars) : ""
}
