locals {
  environments_service_overrides_org_id = merge([for environment, values in var.harness_platform_environments : { for org, details in var.organizations : environment => details.identifier if lower(org) == lower(try(values.organization, "NOT_FOUND")) }]...)
  environments_service_overrides_prj_id = merge([for environment, values in var.harness_platform_environments : { for prj, details in var.projects : environment => details.identifier if lower(prj) == lower(try(values.project, "NOT_FOUND")) }]...)

  environments_service_overrides = merge([
    for svc, variables in var.harness_platform_services : {
      for env, values in try(variables.OVERRIDES.ENV, {}) : "${svc}_${env}" => {
        vars = merge(
          values,
          {
            identifier = "${lower(replace("${svc}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
            org_id     = try(local.environments_service_overrides_org_id[env], "") != "" ? local.environments_service_overrides_org_id[env] : try(variables.SERVICE_DEFINITION.org_id, var.common_values.org_id)
            project_id = try(local.environments_service_overrides_prj_id[env], "") != "" ? local.environments_service_overrides_prj_id[env] : try(variables.SERVICE_DEFINITION.project_id, var.common_values.project_id)
            env_id     = "${lower(replace(env, "/[\\s-.]/", "_"))}_${var.suffix}"
            service_id = "${lower(replace(svc, "/[\\s-.]/", "_"))}_${var.suffix}"
          }
        )
      } if variables.SERVICE_DEFINITION.enable
    }
  ]...)
}

