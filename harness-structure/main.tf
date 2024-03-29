resource "harness_platform_organization" "org" {
  for_each    = local.orgs
  tags        = each.value.tags
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
}

resource "harness_platform_project" "project" {
  for_each    = local.prjs
  tags        = each.value.tags
  identifier  = each.value.identifier
  name        = each.key
  org_id      = each.value.org_id
  description = each.value.description
}
