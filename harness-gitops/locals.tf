locals {
  gitops_org_id = merge([for gitops, values in var.harness_platform_gitops_applications : { for org, details in var.organizations : gitops => details.identifier if lower(org) == lower(try(values.organization, "")) }]...)
  gitops_prj_id = merge([for gitops, values in var.harness_platform_gitops_applications : { for prj, details in var.projects : gitops => details.identifier if lower(prj) == lower(try(values.project, "")) }]...)

  gitops_agents = { for app, details in var.harness_platform_gitops_agent : svc => {
    vars = merge(
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[svc], "") != "" ? local.gitops_org_id[svc] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[svc], "") != "" ? local.gitops_prj_id[svc] : try(details.project_id, var.common_values.project_id)
      }
  ) } if details.enable }

  gitops_cluster = { for app, details in var.harness_platform_gitops_cluster : svc => {
    vars = merge(
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[svc], "") != "" ? local.gitops_org_id[svc] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[svc], "") != "" ? local.gitops_prj_id[svc] : try(details.project_id, var.common_values.project_id)
      }
  ) } if details.enable }

  gitops_applications = { for app, details in var.harness_platform_gitops_applications : svc => {
    vars = merge(
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[svc], "") != "" ? local.gitops_org_id[svc] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[svc], "") != "" ? local.gitops_prj_id[svc] : try(details.project_id, var.common_values.project_id)
      }
  ) } if details.enable }
}
