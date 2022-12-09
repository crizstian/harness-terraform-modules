resource "harness_platform_organization" "org" {
  for_each    = local.orgs
  tags        = each.value.tags
  identifier  = each.value.identifier
  name        = each.key
  description = "${each.key} - ${each.value.description}"
}

resource "harness_platform_project" "seed_org_project" {
  for_each    = local.orgs
  tags        = each.value.tags
  identifier  = "seed_project_${each.value.identifier}"
  name        = "${title(each.value.name)} - Seed Setup"
  description = "${each.key} - Seed Project Generated By Terraform"
  org_id      = harness_platform_organization.org[each.key].identifier
}

resource "harness_platform_project" "project" {
  for_each    = local.projs
  tags        = each.value.tags
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
  value = { for key, details in harness_platform_organization.org : key => {
    org_id          = details.identifier
    seed_project_id = harness_platform_project.seed_org_project[key].identifier
    suffix          = var.suffix
  } }
}
