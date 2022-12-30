resource "harness_platform_policy" "policy" {
  for_each    = local.harness_policies
  name        = each.value.name
  description = each.value.description
  identifier  = each.value.identifier
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  tags        = each.value.tags
  rego        = file("${path.root}/${each.value.file}")
}
