resource "harness_platform_roles" "role" {
  for_each             = local.harness_roles
  name                 = each.value.name
  description          = each.value.description
  identifier           = each.value.identifier
  org_id               = each.value.org_id
  project_id           = each.value.project_id
  tags                 = each.value.tags
  permissions          = each.value.permissions
  allowed_scope_levels = each.value.allowed_scope_levels
}

resource "harness_platform_user" "user" {
  for_each    = local.harness_users
  email       = each.value.email
  user_groups = each.value.user_groups

  dynamic "role_bindings" {
    for_each = each.value.role_bindings
    content {
      resource_group_identifier = role_bindings.value.resource_group_identifier
      role_identifier           = role_bindings.value.role_identifier
      role_name                 = role_bindings.value.role_name
      resource_group_name       = role_bindings.value.resource_group_name
      managed_role              = role_bindings.value.managed_role
    }
  }
}

resource "harness_platform_usergroup" "usergroup" {
  for_each           = local.harness_user_groups
  name               = each.value.name
  description        = each.value.description
  identifier         = each.value.identifier
  org_id             = each.value.org_id
  project_id         = each.value.project_id
  tags               = each.value.tags
  linked_sso_id      = each.value.linked_sso_id
  externally_managed = each.value.externally_managed
  user_emails        = each.value.user_emails

  dynamic "notification_configs" {
    for_each = each.value.notification_configs
    content {
      type                        = notification_configs.value.type
      slack_webhook_url           = try(notification_configs.value.slack_webhook_url, "")
      group_email                 = try(notification_configs.value.group_email, "")
      send_email_to_all_users     = try(notification_configs.value.send_email_to_all_users, "")
      microsoft_teams_webhook_url = try(notification_configs.value.microsoft_teams_webhook_url, "")
      pager_duty_key              = try(notification_configs.value.pager_duty_key, "")
    }
  }

  linked_sso_display_name = each.value.linked_sso_display_name
  sso_group_id            = each.value.sso_group_id // When sso linked type is saml sso_group_id is same as sso_group_name
  sso_group_name          = each.value.sso_group_name
  linked_sso_type         = each.value.linked_sso_type
  sso_linked              = each.value.sso_linked
}

resource "harness_platform_service_account" "service_account" {
  for_each    = local.harness_service_accounts
  name        = each.value.name
  description = each.value.description
  identifier  = each.value.identifier
  tags        = each.value.tags
  email       = each.value.email
  account_id  = each.value.account_id
}

resource "harness_platform_resource_group" "resource_group" {
  for_each    = local.harness_resource_groups
  name        = each.value.name
  description = each.value.description
  identifier  = each.value.identifier
  tags        = each.value.tags
  account_id  = each.value.account_id
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  allowed_scope_levels = each.value.allowed_scope_levels

  dynamic "included_scopes" {
    for_each = each.value.included_scopes
    content {
      filter     = included_scopes.value.filter
      account_id = each.value.account_id
      org_id     = try(each.value.org_id, "")
      project_id = try(each.value.project_id, "")
    }
  }

  dynamic "resource_filter" {
    for_each = each.value.resource_filter
    content {
      include_all_resources = resource_filter.value.include_all_resources
      dynamic "resources" {
        for_each = resource_filter.value.resources
        content {
          resource_type = resources.value.resource_type
          dynamic "attribute_filter" {
            for_each = try(resources.value.attribute_filter, {})
            content {
              attribute_name   = attribute_filter.value.attribute_name
              attribute_values = attribute_filter.value.attribute_values
            }
          }
        }
      }
    }
  }
}

resource "harness_platform_role_assignments" "role_assignments" {
  for_each                  = local.harness_role_assignments
  org_id                    = each.value.org_id
  project_id                = each.value.project_id
  resource_group_identifier = each.value.resource_group_identifier
  role_identifier           = each.value.role_identifier

  dynamic "principal" {
    for_each = each.value.principal
    content {
      identifier = principal.value.identifier
      type       = principal.value.type
    }
  }

  disabled = each.value.disabled
  managed  = each.value.managed
}

resource "harness_platform_apikey" "apikey" {
  for_each    = local.harness_apikey
  name        = each.value.name
  identifier  = each.value.identifier
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  account_id  = each.value.account_id
  parent_id   = each.value.parent_id
  apikey_type = each.value.apikey_type
}

resource "harness_platform_token" "token" {
  for_each              = local.harness_token
  name                  = each.value.name
  identifier            = each.value.identifier
  org_id                = each.value.org_id
  project_id            = each.value.project_id
  account_id            = each.value.account_id
  parent_id             = each.value.parent_id
  apikey_type           = each.value.apikey_type
  apikey_id             = each.value.apikey_id
  description           = each.value.description
  email                 = each.value.email
  encoded_password      = each.value.encoded_password
  scheduled_expire_time = each.value.scheduled_expire_time
  tags                  = each.value.tags
  username              = each.value.username
  valid                 = each.value.valid
  valid_from            = each.value.valid_from
  valid_to              = each.value.valid_to
}