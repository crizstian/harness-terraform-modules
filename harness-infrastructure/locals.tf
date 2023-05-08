locals {
  environment_org_id = merge([for environment, values in var.harness_platform_environments : { for org, details in var.organizations : environment => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  environment_prj_id = merge([for environment, values in var.harness_platform_environments : { for prj, details in var.projects : environment => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  environments = { for name, details in var.harness_platform_environments : name => {
    vars = merge(
      details.vars,
      {
        name       = "${name}"
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags       = concat(try(details.vars.tags, []), var.tags)
        org_id     = try(local.environment_org_id[name], "") != "" ? local.environment_org_id[name] : try(details.vars.org_id, var.org_id)
        project_id = try(local.environment_prj_id[name], "") != "" ? local.environment_prj_id[name] : try(details.vars.project_id, var.project_id)
      }
  ) } if details.enable }

  infrastructure_org_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for org, details in var.organizations : infrastructure => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  infrastructure_prj_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for prj, details in var.projects : infrastructure => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)
  infrastructure_env_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for env, details in harness_platform_environment.environment : infrastructure => details.identifier if lower(env) == lower(try(values.vars.environment, "")) }]...)
  infrastructure_k8s_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in try(var.connectors.kubernetes_connectors, {}) : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...)
  infrastructure_keys   = toset(setsubtract(keys(var.harness_platform_infrastructures), keys(local.infrastructure_k8s_id)))
  infrastructure_tpl_dp_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for tpl, details in try(var.templates.template_deployments, {}) : infrastructure => {
    template-deployment = {
      template_id      = details.identifier
      template_version = element(values(values.template.template-deployment), 0)
    }
  } if lower(tpl) == lower(element(keys(values.template.template-deployment), 0)) }]...)

  infrastructure_k8s = { for name, connector in local.infrastructure_k8s_id : name => {
    vars = merge(
      var.harness_platform_infrastructures[name].vars,
      {
        name         = "${name}"
        identifier   = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags         = concat(try(var.harness_platform_infrastructures[name].vars.tags, []), var.tags)
        env_id       = try(local.infrastructure_env_id[name], "") != "" ? local.infrastructure_env_id[name] : try(var.harness_platform_infrastructures[name].vars.env_id, var.env_id)
        org_id       = try(local.infrastructure_org_id[name], "") != "" ? local.infrastructure_org_id[name] : try(var.harness_platform_infrastructures[name].vars.org_id, var.org_id)
        project_id   = try(local.infrastructure_prj_id[name], "") != "" ? local.infrastructure_prj_id[name] : try(var.harness_platform_infrastructures[name].vars.project_id, var.project_id)
        connector_id = connector
    })
    } if var.harness_platform_infrastructures[name].enable
  }

  infrastructure_not_k8s = { for key, name in local.infrastructure_keys : name => {
    vars = merge(
      var.harness_platform_infrastructures[name].vars,
      try(local.infrastructure_tpl_dp_id[name], {}),
      {
        name       = "${name}"
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags       = concat(try(var.harness_platform_infrastructures[name].vars.tags, []), var.tags)
        env_id     = try(local.infrastructure_env_id[name], "") != "" ? local.infrastructure_env_id[name] : try(var.harness_platform_infrastructures[name].vars.env_id, var.env_id)
        org_id     = try(local.infrastructure_org_id[name], "") != "" ? local.infrastructure_org_id[name] : try(var.harness_platform_infrastructures[name].vars.org_id, var.org_id)
        project_id = try(local.infrastructure_prj_id[name], "") != "" ? local.infrastructure_prj_id[name] : try(var.harness_platform_infrastructures[name].vars.project_id, var.project_id)
    })
    } if var.harness_platform_infrastructures[name].enable
  }

  infrastructures = merge(
    local.infrastructure_k8s,
    local.infrastructure_not_k8s
  )
}

