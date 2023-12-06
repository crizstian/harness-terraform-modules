locals {

  svc_configfiles = merge(flatten([for svc, value in var.services : {
    for env, values in try(value.vars.OVERRIDES.ENV, {}) : "${svc}_${env}" => [

      for cfg, details in values.configfiles : <<-EOT
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

    ] if can(values.configfiles)
    }
  ])...)

  svc_manifests = merge(flatten([for svc, value in var.services : {
    for env, values in try(value.vars.OVERRIDES.ENV, {}) : "${svc}_${env}" => [

      for manifest, details in values.manifests : <<-EOT
      manifest:
        identifier: ${manifest}
        type: ${details.type}
        spec:
          store:
            spec:
              %{if details.git_provider != "Harness"}
              connectorRef: ${try(var.connectors.default_connectors.git_connector_id, "NOT_DEFINED")}
              %{if can(details.reponame)}
              repoName: ${details.reponame}
              %{endif}
              gitFetchType: Branch
              branch: ${details.branch}
              paths:
              %{endif}
              %{if details.git_provider == "Harness"}
              files:
              %{endif}
                - "${details.file}"
            type: ${details.git_provider}
      EOT
      if details.type == "Values"
    ] if can(values.manifests)
    }
  ])...)

  service_overrides = merge([for svc, value in var.services : {
    for env, values in try(value.vars.OVERRIDES.ENV, {}) : "${svc}_${env}" => {
      vars = merge(
        try(value.vars.SERVICE_OVERRIDE, {}),
        {
          identifier  = "${lower(replace("${svc}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
          org_id      = var.environments[env].org_id
          project_id  = var.environments[env].project_id
          env_id      = var.environments[env].identifier
          service_id  = var.services[svc].identifier
          variables   = values.variables
          manifests   = local.svc_manifests["${svc}_${env}"]
          configfiles = local.svc_configfiles["${svc}_${env}"]
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

