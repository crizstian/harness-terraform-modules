locals {
  environments_service_overrides = merge([
    for svc, variables in var.harness_platform_overrides : {
      for env, values in try(variables.OVERRIDES.ENV, {}) : "${svc}_${env}" => {
        vars = merge(
          values,
          {
            identifier = "${lower(replace("${svc}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
            org_id     = var.environments[env].org_id
            project_id = var.environments[env].project_id
            env_id     = var.environments[env].identifier
            service_id = var.services[svc].identifier
          }
        )
      }
    }
  ]...)
}

