resource "harness_platform_organization" "org" {
  for_each    = local.orgs
  identifier  = each.value.identifier
  name        = each.key
  description = "${each.key} - ${each.value.description}"
}

resource "harness_platform_project" "project" {
  for_each    = local.projs
  identifier  = each.value.identifier
  name        = each.key
  description = "${each.key} - ${each.value.description}"
  org_id      = each.value.org_id
}

output "project" {
  value = { for key, details in harness_platform_project.project : key => {
    identifier = details.identifier
    org_id     = details.org_id
    }
  }
}

output "organization" {
  value = { for key, details in harness_platform_organization.org : key => { org_id = details.identifier } }
}
