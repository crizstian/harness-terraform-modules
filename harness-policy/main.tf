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

/* resource "harness_platform_policyset" "test" {
  identifier = "harness_platform_policyset.test.identifier"
  name       = "harness_platform_policyset.test.name"
  action     = "onrun"
  type       = "pipeline"
  enabled    = true
  policies {
    identifier = "policy_identifier"
    severity   = "warning"
  }
} */
