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

  user_org_id = merge([for user, values in var.harness_platform_users : { for org, details in var.organizations : user => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  user_prj_id = merge([for user, values in var.harness_platform_users : { for prj, details in var.projects : user => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_users = {
    for name, details in var.harness_platform_users : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.user_org_id[name], "") != "" ? local.user_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.user_prj_id[name], "") != "" ? local.user_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
        user_groups = try(details.user_groups, [])
        role_bindings = try(details.role_bindings, {})
      }
    )
  }

  user_group_org_id = merge([for user_group, values in var.harness_platform_usergroups : { for org, details in var.organizations : user_group => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  user_group_prj_id = merge([for user_group, values in var.harness_platform_usergroups : { for prj, details in var.projects : user_group => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_user_groups = {
    for name, details in var.harness_platform_usergroups : name => merge(
      details,
      {
        name                    = "${name}"
        identifier              = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags                    = concat(try(details.vars.tags, []), var.tags)
        org_id                  = try(local.user_group_org_id[name], "") != "" ? local.user_group_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id              = try(local.user_group_prj_id[name], "") != "" ? local.user_group_prj_id[name] : try(details.project_id, var.common_values.project_id)
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

  service_account_org_id = merge([for service_account, values in var.harness_platform_service_accounts : { for org, details in var.organizations : service_account => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  service_account_prj_id = merge([for service_account, values in var.harness_platform_service_accounts : { for prj, details in var.projects : service_account => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)
  
  harness_service_accounts = {
    for name, details in var.harness_platform_service_accounts : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.service_account_org_id[name], "") != "" ? local.service_account_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.service_account_prj_id[name], "") != "" ? local.service_account_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
      }
    )
  }

  resource_group_org_id = merge([for resource_group, values in var.harness_platform_resource_groups : { for org, details in var.organizations : resource_group => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  resource_group_prj_id = merge([for resource_group, values in var.harness_platform_resource_groups : { for prj, details in var.projects : resource_group => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_resource_groups = {
    for name, details in var.harness_platform_resource_groups : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.resource_group_org_id[name], "NOT_DEFINED") != "NOT_DEFINED" ? local.resource_group_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.resource_group_prj_id[name], "NOT_DEFINED") != "NOT_DEFINED" ? local.resource_group_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
        included_scopes = try(details.included_scopes, {})
        resource_filter = try(details.resource_filter, {})
      }
    )
  }

  role_assignment_org_id = merge([for role_assignment, values in var.harness_platform_role_assignments : { for org, details in var.organizations : role_assignment => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  role_assignment_prj_id = merge([for role_assignment, values in var.harness_platform_role_assignments : { for prj, details in var.projects : role_assignment => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_role_assignments = {
    for name, details in var.harness_platform_role_assignments : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        org_id      = try(local.role_assignment_org_id[name], "") != "" ? local.role_assignment_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.role_assignment_prj_id[name], "") != "" ? local.role_assignment_prj_id[name] : try(details.project_id, var.common_values.project_id)
        resource_group_identifier = try(var.resource_groups[details.resource_group_identifier].identifier,details.resource_group_identifier)
        role_identifier           = try(var.roles[details.role_identifier].identifier,details.role_identifier)
        principal = {
          for k, v in details.principal: k => {
            identifier = v.type == "USER_GROUP" ? try(var.usergroups[k].identifier, "NOT_DEFINED") : v.type == "SERVICE_ACCOUNT" ? try(var.service_accounts[k].identifier, "NOT_DEFINED") : v.type == "USER" ? try(var.users[k].identifier, "NOT_DEFINED") : v.type == "API_KEY" ? try(var.users[k].identifier, "NOT_DEFINED") : "NOT_DEFINED"
            type = v.type
            scope_level = try(v.scope_level, "")
          }
        }
      }
    )
  }

  apikey_org_id = merge([for apikey, values in var.harness_platform_apikey : { for org, details in var.organizations : apikey => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  apikey_prj_id = merge([for apikey, values in var.harness_platform_apikey : { for prj, details in var.projects : apikey => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)


  harness_apikey = {
    for name, details in var.harness_platform_apikey : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        org_id      = try(local.apikey_org_id[name], "") != "" ? local.apikey_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.apikey_prj_id[name], "") != "" ? local.apikey_prj_id[name] : try(details.project_id, var.common_values.project_id)
      }
    )
  }

  harness_token = merge([
    for name, details in var.harness_platform_apikey : {
      for k, v in try(details.token, {}): k => merge(
      details,
      {
        name                  = "${k}"
        identifier            = "${lower(replace(k, "/[\\s-.]/", "_"))}_${var.suffix}"
        org_id                = local.harness_apikey[name].org_id
        project_id            = local.harness_apikey[name].project_id
        account_id            = local.harness_apikey[name].account_id
        parent_id             = local.harness_apikey[name].parent_id
        apikey_type           = local.harness_apikey[name].apikey_type
        apikey_id             = local.harness_apikey[name].identifier
        description           = try(details.description, "")
        email                 = try(details.email, "")
        encoded_password      = try(details.encoded_password, "")
        scheduled_expire_time = try(details.scheduled_expire_time, 0)
        tags                  = try(details.tags, [""])
        username              = try(details.username, "")
        valid                 = try(details.valid, true)
        valid_from            = try(details.valid_from, 0)
        valid_to              = try(details.valid_to, 0)
      }
    )
    }
  ]...)
}