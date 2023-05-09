resource "harness_platform_triggers" "trigger" {
  for_each    = local.triggers
  name        = each.value.vars.name
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  target_id   = each.value.vars.pipeline_id
  tags        = each.value.vars.tags
  yaml        = templatefile(each.value.vars.yaml, each.value.vars)
}
