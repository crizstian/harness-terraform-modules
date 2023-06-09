locals {
  variable_org_id = merge([for variable, values in var.harness_platform_variables : { for org, details in var.organizations : variable => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  variable_prj_id = merge([for variable, values in var.harness_platform_variables : { for prj, details in var.projects : variable => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  variables = { for name, details in var.harness_platform_variables : name => {
    vars = merge(
      details,
      {
        name       = "${name}"
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        org_id     = try(local.variable_org_id[name], "") != "" ? local.variable_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id = try(local.variable_prj_id[name], "") != "" ? local.variable_prj_id[name] : try(details.project_id, var.common_values.project_id)
      }
  ) } if details.enable }
}
