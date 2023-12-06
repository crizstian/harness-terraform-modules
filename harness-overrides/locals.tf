locals {

  svc_configfiles = merge(flatten([for svc, value in var.services : [
    for env, values in try(value.vars.OVERRIDES.ENV, {}) : {
      for cfg, details in values.configfiles : "${svc}_${env}" => <<-EOT
      configFile:
        identifier: ${cfg}
        spec:
          store:
            spec:
              %{if details.type == "encrypted"}
              secretFiles:
                - ${details.file}
              %{endif}
            type: ${details.store}
          configFileAttributeStepParameters:
            store:
              type: ${details.store}
              spec:
                type: ${details.store}
                %{if details.type == "encrypted"}
                secretFiles:
                  - ${details.file}
                %{endif}
      EOT
    } if can(values.configfiles)
    ]
  ])...)

  service_overrides = merge([for svc, value in var.services : {
    for env, values in try(value.vars.OVERRIDES.ENV, {}) : "${svc}_${env}" => {
      vars = merge(
        try(value.SERVICE_OVERRIDE, {}),
        {
          identifier  = "${lower(replace("${svc}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
          org_id      = var.environments[env].org_id
          project_id  = var.environments[env].project_id
          env_id      = var.environments[env].identifier
          service_id  = var.services[svc].identifier
          variables   = []
          manifests   = []
          configFiles = local.svc_configfiles["${svc}_${env}"]
        }
      )
    }
    }
    ]...
  )


  # environments_service_overrides = merge([
  #   for svc, variables in var.harness_platform_overrides : {
  #     for env, values in try(variables.OVERRIDES.ENV, {}) : "${svc}_${env}" => {
  #       vars = merge(
  #         values,
  #         {
  #           identifier = "${lower(replace("${svc}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
  #           org_id     = var.environments[env].org_id
  #           project_id = var.environments[env].project_id
  #           env_id     = var.environments[env].identifier
  #           service_id = var.services[svc].identifier
  #         }
  #       )
  #     }
  #   }
  # ]...)
}

