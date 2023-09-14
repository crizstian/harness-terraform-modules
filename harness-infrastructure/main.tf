resource "harness_platform_environment" "environment" {
  for_each    = local.environments
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.vars.tags
  type        = each.value.vars.type
  yaml        = can(each.value.vars.yaml) ? templatefile(each.value.vars.yaml, each.value.vars) : ""
}

resource "harness_platform_infrastructure" "infrastructure" {
  for_each    = local.infrastructures
  name        = each.value.name
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  env_id      = each.value.vars.env_id
  tags        = each.value.vars.tags
  type        = each.value.vars.type
  yaml        = can(each.value.vars.yaml) ? templatefile(each.value.vars.yaml, each.value.vars) : ""
}
