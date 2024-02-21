locals {
  policy_org_id = merge([for policy, values in var.harness_platform_policies : { for org, details in var.organizations : policy => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  policy_prj_id = merge([for policy, values in var.harness_platform_policies : { for prj, details in var.projects : policy => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_policies = {
    for name, details in var.harness_platform_policies : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.policy_org_id[name], "") != "" ? local.policy_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.policy_prj_id[name], "") != "" ? local.policy_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
      }
    )
  }

  policy_sets_org_id = merge([for policy, values in var.harness_platform_policy_sets : { for org, details in var.organizations : policy => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  policy_sets_prj_id = merge([for policy, values in var.harness_platform_policy_sets : { for prj, details in var.projects : policy => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  harness_policy_sets = {
    for name, details in var.harness_platform_policy_sets : name => merge(
      details,
      {
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.policy_sets_org_id[name], "") != "" ? local.policy_sets_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.policy_sets_prj_id[name], "") != "" ? local.policy_sets_prj_id[name] : try(details.project_id, var.common_values.project_id)
        description = details.description
        policies = { for k, v in details.policies : k => {
          identifier = try(var.var.policies[k].identifier, "NOT_DEFINED")
          severity   = v.severity
          }
        }
      }
    )
  }
}
