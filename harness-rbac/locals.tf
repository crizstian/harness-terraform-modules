locals {
  role_org_id = merge([for role, values in var.harness_platform_roles : { for org, details in var.organizations : role => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  role_prj_id = merge([for role, values in var.harness_platform_roles : { for prj, details in var.projects : role => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)


  harness_roles = {
    for name, details in var.harness_platform_roles : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
      }
    )
  }
  harness_users = {
    for name, details in var.harness_platform_users : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
      }
    )
  }
  harness_user_groups = {}
  harness_service_accounts = {
    for name, details in var.harness_platform_users : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
      }
    )
  }
}
