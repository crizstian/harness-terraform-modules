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
        user_groups = try(details.user_groups, [])
        role_bindings = try(details.role_bindings, {})
      }
    )
  }
  harness_user_groups = {
    for name, details in var.harness_platform_usergroups : name => merge(
      details,
      {
        name                    = "${name}"
        identifier              = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags                    = concat(try(details.vars.tags, []), var.tags)
        org_id                  = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id              = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description             = details.description
        linked_sso_id           = try(details.linked_sso_id, "")
        externally_managed      = try(details.externally_managed, false)
        user_emails             = try(details.user_emails, [])
        notification_configs    = try(details.notification_configs, {})
        linked_sso_display_name = try(details.linked_sso_display_name, "")
        sso_group_id            = try(details.sso_group_id, "")
        sso_group_name          = try(details.sso_group_name, "")
        linked_sso_type         = try(details.linked_sso_type, "")
        sso_linked              = try(details.sso_linked, false)
      }
    )
  }
  harness_service_accounts = {
    for name, details in var.harness_platform_service_accounts : name => merge(
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
  harness_resource_groups = {
    for name, details in var.harness_platform_resource_groups : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
        included_scopes = try(details.included_scopes, {})
        resource_filter = try(details.resource_filter, {})
      }
    )
  }
  harness_role_assignments = {
    for name, details in var.harness_platform_role_assignments : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.role_org_id[name], "") != "" ? local.role_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_prj_id[name], "") != "" ? local.role_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
        resource_group_identifier = try(var.roles[details.resource_group_identifier],details.resource_group_identifier)
        role_identifier           = try(var.esource_groups[details.role_identifier],details.role_identifier)
        principal = {
          for k, v in details.principal: k => {
            identifier = v.type == "USER_GROUP" ? try(var.usergroups[k].identifier, "NOT_DEFINED") : v.type == "SERVICE_ACCOUNT" ? try(var.service_accounts[k].identifier, "NOT_DEFINED") : v.type == "USER" ? try(var.users[k].identifier, "NOT_DEFINED") : v.type == "API_KEY" ? try(var.users[k].identifier, "NOT_DEFINED") : "NOT_DEFINED"
            type = v.type
          }
        }
      }
    )
  }
}