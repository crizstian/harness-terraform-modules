resource "harness_platform_policy" "policy" {
  for_each    = local.harness_policies
  name        = each.value.name
  description = each.value.description
  identifier  = each.value.identifier
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  tags        = each.value.tags
  rego        = file(each.value.file)
}

resource "harness_platform_policyset" "policyset" {
  for_each   = local.harness_policy_sets
  identifier = each.value.identifier
  name       = each.value.name
  action     = each.value.action
  type       = each.value.type
  enabled    = each.value.enabled

  dynamic "policies" {
    for_each = each.value.policies
    content {
      identifier = policies.value.identifier
      severity   = policies.value.severity
    }
  }
}
