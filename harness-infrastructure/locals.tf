locals {
  environment_org_id = merge([for environment, values in var.harness_platform_environments : { for org, details in var.organizations : environment => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  environment_prj_id = merge([for environment, values in var.harness_platform_environments : { for prj, details in var.projects : environment => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  environments = { for name, details in var.harness_platform_environments : name =>
    {
      vars = merge(
        details,
        {
          name       = "${name}"
          identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
          tags       = concat(try(details.vars.tags, []), var.tags)
          org_id     = try(local.environment_org_id[name], "") != "" ? local.environment_org_id[name] : try(details.org_id, var.common_values.org_id)
          project_id = try(local.environment_prj_id[name], "") != "" ? local.environment_prj_id[name] : try(details.project_id, var.common_values.project_id)
        }
      )
    } if details.enable
  }

  infrastructure_org_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for org, details in var.organizations : infrastructure => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  infrastructure_prj_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for prj, details in var.projects : infrastructure => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)
  infrastructure_env_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for env, details in harness_platform_environment.environment : infrastructure => details.identifier if lower(env) == lower(try(values.vars.environment, "NOT_FOUND")) }]...)
  infrastructure_k8s_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in try(var.connectors.kubernetes_connectors, {}) : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...)
  #infrastructure_keys   = toset(setsubtract(keys(var.harness_platform_infrastructures), keys(local.infrastructure_k8s_id)))
  infrastructure_tpl_dp_id = { for infrastructure, values in var.harness_platform_infrastructures : infrastructure =>
    {
      template-deployment = {
        template_id      = try(var.templates.template_deployments[values.template.template-deployment.template_name].identifier, "NOT_FOUND")
        template_version = try(values.template.template-deployment.template_version, "NOT_FOUND")
      }
    }
  }

  infrastructure_k8s = merge(
    [
      for type, values in var.harness_platform_infrastructures : {
        for infra, details in values.infrastructure : "${type}_${infra}" => {
          vars = merge(
            values,
            details,
            {
              name         = infra
              identifier   = "${lower(replace("${type}_${infra}", "/[\\s-.]/", "_"))}_${var.suffix}"
              tags         = concat(try(values.vars.tags, []), var.tags)
              org_id       = try(local.infrastructure_org_id[type], "") != "" ? local.infrastructure_org_id[type] : try(values.vars.org_id, var.common_values.org_id)
              project_id   = try(local.infrastructure_prj_id[type], "") != "" ? local.infrastructure_prj_id[type] : try(values.vars.project_id, var.common_values.project_id)
              connector_id = try(var.connectors.kubernetes_connectors[infra].identifier, "NOT_FOUND")
              env_id       = harness_platform_environment.environment[details.environment].identifier
            }
          )
        } if details.enable
      }
    ]...
  )

  /* infrastructure_not_k8s = merge([
    for type, values in var.harness_platform_infrastructures : {
      for infra, details in values.infrastructure : infra => {
        vars = merge(
          try(local.infrastructure_tpl_dp_id[infra], {}),
          values,
          details,
          {
            name       = infra
            identifier = "${lower(replace(infra, "/[\\s-.]/", "_"))}_${var.suffix}"
            tags       = concat(try(values.vars.tags, []), var.tags)
            org_id     = try(local.infrastructure_org_id[type], "") != "" ? local.infrastructure_org_id[type] : try(values.vars.org_id, var.common_values.org_id)
            project_id = try(local.infrastructure_prj_id[type], "") != "" ? local.infrastructure_prj_id[type] : try(values.vars.project_id, var.common_values.project_id)
            env_id     = harness_platform_environment.environment[details.environment].identifier
          },
        )
      } if details.enable && values.type != "KubernetesDirect"
    }
  ]...) */

  infrastructures = merge(
    local.infrastructure_k8s,
    /* local.infrastructure_not_k8s */
  )
}

