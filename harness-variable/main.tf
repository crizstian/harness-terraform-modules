resource "harness_platform_variables" "variables" {
  for_each    = local.variables
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  type        = each.value.vars.type
  spec {
    value_type  = "FIXED"
    fixed_value = each.value.vars.value
  }
}
