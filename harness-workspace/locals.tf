locals {
  workspace_org_id = merge([for workspace, values in var.harness_platform_workspaces : { for org, details in var.organizations : workspace => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  workspace_prj_id = merge([for workspace, values in var.harness_platform_workspaces : { for prj, details in var.projects : workspace => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  workspaces = { for name, details in var.harness_platform_workspaces : name => merge(
    details,
    {
      identifier              = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      org_id                  = try(local.workspace_org_id[name], "") != "" ? local.workspace_org_id[name] : try(details.org_id, var.common_values.org_id)
      project_id              = try(local.workspace_prj_id[name], "") != "" ? local.workspace_prj_id[name] : try(details.project_id, var.common_values.project_id)
      terraform_variable      = try(details.terraform_variable, {})
      environment_variable    = try(details.environment_variable, {})
      terraform_variable_file = try(details.terraform_variable_file, {})
    }
  ) if details.enable }
}
