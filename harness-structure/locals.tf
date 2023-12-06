locals {
  orgs = { for name, details in var.harness_platform_organizations : name => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      tags       = concat(try(details.tags, []), var.tags)
    })
    if details.enable && name != "default"
  }

  prj_org_ids = { for org, details in harness_platform_organization.org : lower(org) => details.identifier }

  prjs = { for name, details in var.harness_platform_projects : name =>
    merge(
      details,
      {
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags       = concat(try(details.tags, []), var.tags)
        org_id     = try(local.prj_org_ids[lower(details.organization)], try(details.org_id, ""))
    })
    if details.enable
  }
}
