locals {
  gitops_org_id = merge([for gitops, values in var.harness_platform_gitops_applications : { for org, details in var.organizations : gitops => details.identifier if lower(org) == lower(try(values.organization, "")) }]...)
  gitops_prj_id = merge([for gitops, values in var.harness_platform_gitops_applications : { for prj, details in var.projects : gitops => details.identifier if lower(prj) == lower(try(values.project, "")) }]...)

  gitops_agents = { for app, details in var.harness_platform_gitops_agent : app => merge(
      details,
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[app], "") != "" ? local.gitops_org_id[app] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[app], "") != "" ? local.gitops_prj_id[app] : try(details.project_id, var.common_values.project_id)
      }
  ) if details.enable }

  gitops_cluster = { for app, details in var.harness_platform_gitops_cluster : app => {
    vars = merge(
      details,
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[app], "") != "" ? local.gitops_org_id[app] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[app], "") != "" ? local.gitops_prj_id[app] : try(details.project_id, var.common_values.project_id)
        agent_id   = try(harness_platform_gitops_agent.cluster[details.agent].agent_id, details.agent_id)
      }
  ) } if details.enable }

  gitops_applications = { for app, details in var.harness_platform_gitops_applications : app => {
    vars = merge(
      details,
      {
        identifier    = "${lower(replace(app, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags          = concat([], var.tags)
        org_id        = try(local.gitops_org_id[app], "") != "" ? local.gitops_org_id[app] : try(details.org_id, var.common_values.org_id)
        project_id    = try(local.gitops_prj_id[app], "") != "" ? local.gitops_prj_id[app] : try(details.project_id, var.common_values.project_id)
      }
  ) } if details.enable }
}
