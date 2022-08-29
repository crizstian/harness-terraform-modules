resource "harness_platform_organization" "org" {
  for_each    = local.orgs
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
}

resource "harness_platform_project" "project" {
  for_each    = local.projs
  identifier  = each.value.identifier
  name        = each.key
  description = each.value.description
  org_id      = each.value.org_id
}

output "project" {
  value = {
    details = { for key, details in harness_platform_project.project : key => {
      identifier = details.identifier
      org_id     = details.org_id
      }
    }
  }
}
