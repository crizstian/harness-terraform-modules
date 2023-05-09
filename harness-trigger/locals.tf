# github pipelines
locals {
  inputsets         = var.inputsets.inputset
  inputsets_verbose = var.inputsets.verbose
  #inputset = var.inputsets.inputset

  trg_by_svc = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in variables.PIPELINE : {
          for trg, definition in values.TRIGGER : "${svc}_${name}_${trg}" =>
          merge(
            try(var.templates.stages[name].default_values, try(var.templates.pipelines[pipe].default_values, {})),
            try(var.connectors.default_connectors, {}),
            try(variables.CI, {}),
            try(variables.CONNECTORS, {}),
            details,
            definition,
            {
              svc         = "${svc}"
              trg         = "${trg}"
              name        = "${name}"
              suffix      = var.suffix
              tags        = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
              org_id      = try(var.pipelines[pipe].org_id, "") != "" ? var.pipelines[pipe].org_id : try(details.org_id, var.org_id)
              project_id  = try(var.pipelines[pipe].project_id, "") != "" ? var.pipelines[pipe].project_id : try(details.project_id, var.project_id)
              pipeline_id = try(var.pipelines[pipe].identifier, "")
            }
          ) if definition.enable && name == pipe
        } #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable
  ])...)

  ci = { for name, values in local.trg_by_svc : name =>
    {
      vars = merge(
        merge([for inpt, enable in values.TRIGGER_INPUTSET : try(local.inputsets_verbose["${values.svc}_${values.name}_${inpt}"], {}) if enable]...),
        values,
        {
          name         = "${values.svc}_${values.trg}"
          identifier   = "${lower(replace("${values.svc}_${values.trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
          inputset_ids = try([for inpt, enable in values.TRIGGER_INPUTSET : local.inputsets["${values.svc}_${values.name}_${inpt}"].identifier if enable], [])
        }
      )
    } if values.type == "CI"
  }

  trg_by_infra = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in variables.PIPELINE : [
          for trg, definition in values.TRIGGER : {
            for env, infra in variables.CD.ENV : "${svc}_${name}_${env}" =>
            merge(
              infra,
              local.trg_by_svc["${svc}_${name}_${trg}"],
              {
                env    = "${env}"
                env_id = "${lower(env)}_${var.suffix}"
              }
            ) if infra.enable
          } if definition.enable && name == pipe
        ] #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "CD"
  ])...)

  cd = { for name, values in local.trg_by_infra : name =>
    {
      vars = merge(
        values,
        merge([for inpt, enable in values.TRIGGER_INPUTSET : try(local.inputsets_verbose["${values.svc}_${values.name}_${inpt}"], {}) if enable]...),
        {
          name         = "${values.svc}_${values.trg}_${values.env}"
          identifier   = "${lower(replace("${values.svc}_${values.trg}_${values.env}", "/[\\s-.]/", "_"))}_${var.suffix}"
          inputset_ids = try([for inpt, enable in values.TRIGGER_INPUTSET : local.inputsets["${values.svc}_${values.name}_${inpt}"].identifier if enable], [])
        }
      )
    } if values.type == "CD"
  }

  /* cd_type_trigger = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : [
        for trg, values in variables.TRIGGER : {
          for env, infra in variables.CD.ENV : "${svc}_${name}_${trg}_${env}" =>
          {
            vars = merge(
              merge([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : try(local.inputset_by_infra["${svc}_${name}_${env}"], {}) if enable]...),
              local.trigger_by_svc["${svc}_${name}_${trg}"],
              {
                name         = "${svc}_${trg}_${env}"
                identifier   = "${lower(replace("${svc}_${trg}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
                inputset_ids = try([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : harness_platform_input_set.inputset["${svc}_${name}_${env}"].identifier if enable], [])
              }
            )
          }
          if infra.enable
        }
        if try(values.PIPELINE[name].enable, false)
      ]
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CD" && "ALL" != try(details.env_type, "")
  ])...) */

  /* 
  inputset_by_all_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for inpt, values in variables.INPUTSET : "${svc}_${name}_ALL" =>
        merge(
          local.inputset_by_svc["${svc}_${name}_${inpt}"],
          [for env, infra in variables.CD.ENV : {
            "${lower(env)}_infrastructure_id"    = infra.infrastructure_id
            "${lower(env)}_kubernetes_namespace" = infra.kubernetes_namespace
          }]...
        )
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && (details.type == "CD" || details.type == "chained-pipeline") && "ALL" == try(details.env_type, "")
  ])...)

  cd_type_inputset_all = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for inpt, values in variables.INPUTSET : "${svc}_${name}_ALL" =>
        {
          vars = merge(
            local.inputset_by_all_infra["${svc}_${name}_ALL"],
            {
              name       = "${svc}_${inpt}_ALL"
              identifier = "${lower(replace("${svc}_${inpt}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CD" && "ALL" == try(details.env_type, "")
  ])...)


  chain_type_inputset_all = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for inpt, values in variables.INPUTSET : "${svc}_${name}_${inpt}_ALL" =>
        {
          vars = merge(
            local.inputset_by_all_infra["${svc}_${name}_ALL"],
            {
              name                = "${svc}_${inpt}_ALL"
              identifier          = "${lower(replace("${svc}_${inpt}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
              pipeline_id         = harness_platform_pipeline.chained_pipelines[name].identifier
              chained_pipeline_id = harness_platform_pipeline.pipeline[values.PIPELINE[name].chained_pipeline].identifier
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "chained-pipeline" && "ALL" == try(details.env_type, "")
  ])...)

  chain_type_trigger_all = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : {
        for trg, values in variables.TRIGGER : "${svc}_${name}_${trg}_ALL" =>
        {
          vars = merge(
            merge([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : try(local.inputset_by_all_infra["${svc}_${name}_ALL"], {}) if enable]...),
            local.trigger_by_svc["${svc}_${name}_${trg}"],
            {
              name        = "${svc}_${trg}_ALL"
              identifier  = "${lower(replace("${svc}_${trg}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
              pipeline_id = harness_platform_pipeline.chained_pipelines[name].identifier
              # chained_pipeline_id = harness_platform_pipeline.pipeline[values.PIPELINE[name].chained_pipeline].identifier 
              inputset_ids = try([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : harness_platform_input_set.inputset["${svc}_${name}_${inpt}_ALL"].identifier if enable], [])
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "chained-pipeline" && "ALL" == try(details.env_type, "")
  ])...)

  cd_type_trigger_all = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : {
        for trg, values in variables.TRIGGER : "${svc}_${name}_${trg}_ALL" =>
        {
          vars = merge(
            #merge([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : try(local.inputset_by_infra["${svc}_${name}_${env}"], {}) if enable]...), 
            local.trigger_by_svc["${svc}_${name}_${trg}"],
            local.inputset_by_all_infra["${svc}_${name}_ALL"],
            {
              name         = "${svc}_${trg}_ALL"
              identifier   = "${lower(replace("${svc}_${trg}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
              inputset_ids = [harness_platform_input_set.inputset["${svc}_${name}_ALL"].identifier]
              yaml         = details.yaml
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CD" && "ALL" == try(details.env_type, "")
  ])...) */

  triggers = merge(
    local.ci,
    local.cd,
  )
}

output "trg_by_svc" {
  value = local.trg_by_svc
}
output "trg_by_infra" {
  value = local.trg_by_infra
}
output "ci" {
  value = local.ci
}
output "cd" {
  value = local.cd
}
