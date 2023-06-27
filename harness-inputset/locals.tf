# github pipelines
locals {

  inpt_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in try(variables.PIPELINE, {}) : {
          for inpt, set in values.INPUTSET : "${svc}_${name}_${inpt}" =>
          merge(
            try(var.templates.stages[name].default_values, try(var.templates.pipelines[pipe].default_values, {})),
            try(var.connectors.default_connectors, {}),
            try(variables.CONNECTORS, {}),
            try(variables.CI, {}),
            details,
            var.pipelines[pipe].default_values,
            set.VALUES,
            {
              svc                            = "${svc}"
              inpt                           = "${inpt}"
              suffix                         = var.suffix
              tags                           = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
              git_details                    = try(variables.SERVICE_DEFINITION.git_details, {})
              "${variables.type}_service_id" = try("${replace(svc, "-", "_")}_${var.suffix}", "")
              org_id                         = try(var.pipelines[pipe].org_id, "") != "" ? var.pipelines[pipe].org_id : try(details.org_id, var.org_id)
              project_id                     = try(var.pipelines[pipe].project_id, "") != "" ? var.pipelines[pipe].project_id : try(details.project_id, var.project_id)
              pipeline_id                    = try(var.pipelines[pipe].identifier, "")
            }
          ) if try(set.enable, false) && name == pipe
        } #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable
  ])...)

  ci = { for name, values in local.inpt_by_svc : name =>
    {
      vars = merge(
        values,
        {
          name       = "${values.svc}_${values.inpt}"
          identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        }
      )
    } if values.type == "CI"
  }

  inpt_by_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in try(variables.PIPELINE, {}) : [
          for inpt, set in values.INPUTSET : {
            for env, infra in variables.CD.ENV : "${svc}_${name}_${inpt}_${env}" =>
            merge(
              infra,
              local.inpt_by_svc["${svc}_${name}_${inpt}"],
              {
                env                                   = "${env}"
                env_id                                = var.environments[env].identifier
                "${variables.type}_infrastructure_id" = var.infrastructures["${variables.type}_${infra.infrastructure}"].identifier
              }
            ) if infra.enable && lower(var.environments[env].type) == lower(set.type)
          } if try(set.enable, false) && name == pipe
        ] #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "CD"
  ])...)

  cd = { for name, values in local.inpt_by_infra : name =>
    {
      vars = merge(
        values,
        {
          name       = "${values.svc}_${values.inpt}_${values.env}"
          identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        }
      )
    } if values.type == "CD"
  }



  /* trigger_by_svc = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : {
        for trg, values in variables.TRIGGER : "${svc}_${name}_${trg}" =>
        merge(
          details,
          variables.CONNECTORS,
          variables.CI,
          try(values.PIPELINE[name].TRIGGER_SETUP, {}),
          try(values.PIPELINE[name].TRIGGER_VALUES, {}),
          {
            suffix      = var.suffix
            tags        = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
            org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
            project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
            pipeline_id = try(harness_platform_pipeline.pipeline[name].identifier, "")
          }
        )
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable
  ])...) */

  /* ci_type_trigger = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.harness_platform_services : {
        for trg, values in variables.TRIGGER : "${svc}_${name}_${trg}" =>
        {
          vars = merge(
            merge([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : try(local.inputset_by_svc["${svc}_${name}_${inpt}"], {}) if enable]...),
            local.trigger_by_svc["${svc}_${name}_${trg}"],
            {
              name         = "${svc}_${trg}"
              identifier   = "${lower(replace("${svc}_${trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
              inputset_ids = try([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : harness_platform_input_set.inputset["${svc}_${name}_${inpt}"].identifier if enable], [])
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CI"
  ])...) */

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

  chained_pipelines = { for name, details in var.harness_platform_pipelines : name => {
    vars = merge(
      details.vars,
      merge([for temp, values in details.template : merge(
        try(var.templates.stages[values.name].default_values, try(var.templates.pipelines[values.name].default_values, {})),
      )]...),
      {
        suffix      = var.suffix
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
        project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
        git_details = try(details.vars.git_details, {})
        template = {
          for temp, values in details.template : temp => {
            id = temp == "chained" ? try(harness_platform_pipeline.pipeline[values.name].identifier, "") : try(
              var.templates.stages[values.name].identifier,
              try(var.templates.pipelines[values.name].identifier, "")
            )
            version = values.version
          }
        }
        # template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) 
      }
  ) } if details.enable && details.type == "chained-pipeline" }

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

  inputsets = merge(
    local.ci,
    local.cd,
  )

  /* triggers = merge(
    local.ci_type_trigger,
    local.cd_type_trigger,
    local.cd_type_trigger_all,
    local.chain_type_trigger_all
  ) */

}
