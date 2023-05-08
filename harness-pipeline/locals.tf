# github pipelines
locals {

  pipeline_org_id = merge([for pipeline, values in var.harness_platform_pipelines : { for org, details in var.organizations : pipeline => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  pipeline_prj_id = merge([for pipeline, values in var.harness_platform_pipelines : { for prj, details in var.projects : pipeline => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  /* connector_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in var.connectors.kubernetes_connectors : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...) */

  /* templates = { for name, details in var.harness_platform_pipelines : name =>
    {
      org_id           = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
      project_id       = ""
      template_id      = try(element(split(".", details.vars.template.id), 1), {})
      template_version = try(details.vars.template.version, {})
    }
  if details.enable } */

  templates = {}
  /* 
  templated_pipeline = { for name, details in var.harness_platform_pipelines : name =>
    {

    }
  if details.enable } */

  pipeline_tpl_id = { for pipeline, values in var.harness_platform_pipelines : pipeline =>
    {
      pipeline = {
        template_id      = try(var.templates.pipelines[values.template.pipeline.template_name].identifier, "")
        template_version = try(values.template.pipeline.template_version, "")
      }
    }
  }

  pipelines = { for name, details in var.harness_platform_pipelines : name => {
    vars = merge(
      details.vars,
      try(local.pipeline_tpl_id[name], {}),
      try(var.templates.stages[name].default_values, try(var.templates.pipelines[name].default_values, {})),
      {
        suffix      = var.suffix
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
        project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
        git_details = try(details.vars.git_details, {})
        template = {
          id      = try(var.templates.stages[name].identifier, try(var.templates.pipelines[name].identifier, {}))
          version = details.template.version
        }
        /* template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) */
      }
  ) } if details.enable && details.type == "pipeline" }


  inputset_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for inpt, values in variables.INPUTSET : "${svc}_${name}_${inpt}" =>
        merge(
          details,
          variables.CONNECTORS,
          variables.CI,
          try(var.templates.stages[name].default_values, try(var.templates.pipelines[name].default_values, {})),
          try(values.PIPELINE[name].default_values, {}),
          {
            suffix      = var.suffix
            tags        = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
            git_details = try(variables.SERVICE_DEFINITION.git_details, {})
            org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
            project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
            service_id  = try("${replace(svc, "-", "_")}_${var.suffix}", "") #try("${replace(variables.CI.DOCKER_IMAGE_NAME, "-", "_")}_${var.suffix}", "")
            pipeline_id = try(harness_platform_pipeline.pipeline[name].identifier, "")
          },
        )
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable
  ])...)

  inputset_by_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for inpt, values in variables.INPUTSET : {
          for env, infra in variables.CD.ENV : "${svc}_${name}_${env}" =>
          merge(
            local.inputset_by_svc["${svc}_${name}_${inpt}"],
            infra,
            {
              env = "${lower(env)}_${var.suffix}"
            }
          )
          if infra.enable
        }
        if try(values.PIPELINE[name].enable, false)
      ]
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CD"
  ])...)

  ci_type_inputset = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for inpt, values in variables.INPUTSET : "${svc}_${name}_${inpt}" =>
        {
          vars = merge(
            local.inputset_by_svc["${svc}_${name}_${inpt}"],
            {
              name       = "${svc}_${inpt}"
              identifier = "${lower(replace("${svc}_${inpt}", "/[\\s-.]/", "_"))}_${var.suffix}"
            }
          )
        }
        if try(values.PIPELINE[name].enable, false)
      }
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable && details.type == "CI"
  ])...)

  cd_type_inputset = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for inpt, values in variables.INPUTSET : {
          for env, infra in variables.CD.ENV : "${svc}_${name}_${inpt}_${env}" =>
          {
            vars = merge(
              local.inputset_by_infra["${svc}_${name}_${env}"],
              {
                name       = "${svc}_${inpt}_${env}"
                identifier = "${lower(replace("${svc}_${inpt}_${env}", "/[\\s-.]/", "_"))}_${var.suffix}"
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
  ])...)

  trigger_by_svc = merge(flatten([
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
  ])...)

  ci_type_trigger = merge(flatten([
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
  ])...)

  cd_type_trigger = merge(flatten([
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
  ])...)


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
        /* template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) */
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
              /* chained_pipeline_id = harness_platform_pipeline.pipeline[values.PIPELINE[name].chained_pipeline].identifier */
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
            /* merge([for inpt, enable in values.PIPELINE[name].TRIGGER_INPUTSET : try(local.inputset_by_infra["${svc}_${name}_${env}"], {}) if enable]...), */
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
  ])...)



  /* triggers = merge(flatten(
    [for name, details in var.harness_platform_triggers :
      [for trg_by_svc, v in details.services :
        { for trg, val in v.triggers : "${trg_by_svc}_${name}_${trg}" =>
          {
            vars = merge(
              local.trigger_by_svc["${trg_by_svc}_${name}"],
              {
                name       = "${trg_by_svc}_${name}_${trg}"
                identifier = "${lower(replace("${trg_by_svc}_${name}_${trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
                inputset_ids = flatten(
                  [for inpt, values in harness_platform_input_set.inputset :
                    [for trg_by_inpt, enable in val.inputsets : values.identifier
                      if enable && lower(inpt) == lower(try("${trg_by_svc}_${name}_${trg_by_inpt}", ""))
                    ]
                  ],
                )
              },
              try(val.values, {})
            )
          }
        if val.enable }
      if v.enable]
  if details.enable && details.type == "TRIGGER"])...) */


  /* ci_trigger_by_svc = merge(flatten(
    [for name, details in var.harness_platform_triggers :
      { for trg_by_svc, v in details.services : "${trg_by_svc}_${name}" =>
        merge(
          details,
          var.harness_platform_variables[trg_by_svc].CONNECTORS,
          {
            suffix      = var.suffix
            tags        = concat(try(details.v.tags, []), var.tags)
            org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
            project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
            yaml        = details.yaml
          }
        )
      if v.enable }
  if details.enable && details.type == "TRIGGER"])...) */

  /* trigger_inputset_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for inpt, svc_values in variables.INPUTSETS : {
          for trg, values in variables.TRIGGERS : "${svc}_${inpt}_${trg}" => {
            vars = merge(
              local.simple_inputset_by_svc["${svc}_${inpt}"],
            )
          }
          if value.enable
        }
        if svc_values.enable
      ]
      if variables.SERVICE_DEFINITION.enable
    ]
    if details.enable
  ])...) */


  /* CI_inputsets = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      [for inpt_by_svc, v in details.services :
        { for inpt_by_trg, enable in v.triggers : "${inpt_by_svc}_${name}_${inpt_by_trg}" =>
          {
            vars = merge(
              local.inputset_by_svc["${inpt_by_svc}_${name}"],
              var.harness_platform_variables[inpt_by_svc].TRIGGER[inpt_by_trg],
              {
                name       = "${inpt_by_svc}_${name}_${inpt_by_trg}"
                identifier = "${lower(replace("${inpt_by_svc}_${name}_${inpt_by_trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
              }
            )
          }
        if enable }
      if v.enable]
  if details.enable && details.type == "CI"])...) */


  /* CI_inputsets = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      [for inpt_by_svc, v in details.services :
        { for inpt_by_trg, enable in v.triggers : "${inpt_by_svc}_${name}_${inpt_by_trg}" =>
          {
            vars = merge(
              local.inputset_by_svc["${inpt_by_svc}_${name}"],
              var.harness_platform_variables[inpt_by_svc].TRIGGER[inpt_by_trg],
              {
                name       = "${inpt_by_svc}_${name}_${inpt_by_trg}"
                identifier = "${lower(replace("${inpt_by_svc}_${name}_${inpt_by_trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
              }
            )
          }
        if enable }
      if v.enable]
  if details.enable && details.type == "CI"])...)

  inputset_by_infra = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      [for inpt_by_svc, v in details.services :
        { for inpt_by_env, values in var.harness_platform_variables[inpt_by_svc].CD.ENV : "${inpt_by_svc}_${name}_${inpt_by_env}" =>
          merge(
            values,
            local.inputset_by_svc["${inpt_by_svc}_${name}"],
            var.harness_platform_variables[inpt_by_svc].CD.VARIABLES,
            var.harness_platform_variables[inpt_by_svc].CD.ENV[inpt_by_env],
          )
        if values.enable && values.type == details.env_type }
      if v.enable]
  if details.enable && details.type == "CD"])...)

  CD_inputsets = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      [for inpt_by_svc, v in details.services :
        [for inpt_by_env, values in var.harness_platform_variables[inpt_by_svc].CD.ENV :
          { for inpt_by_trg, enable in v.triggers : "${inpt_by_svc}_${name}_${inpt_by_env}_${inpt_by_trg}" =>
            {
              vars = merge(
                local.inputset_by_infra["${inpt_by_svc}_${name}_${inpt_by_env}"],
                var.harness_platform_variables[inpt_by_svc].TRIGGER[inpt_by_trg],
                {
                  name       = "${inpt_by_svc}_${name}_${inpt_by_env}_${inpt_by_trg}"
                  identifier = "${lower(replace("${inpt_by_svc}_${name}_${inpt_by_env}_${inpt_by_trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
                  env        = "${lower(inpt_by_env)}_${var.suffix}"
                }
              )
            }
          if enable }
        if values.enable && values.type == details.env_type]
      if v.enable]
  if details.enable && details.type == "CD"])...)

  inputset_all_infra = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      { for inpt_by_svc, v in details.services : "${inpt_by_svc}_${name}_ALL" =>
        merge(
          local.inputset_by_svc["${inpt_by_svc}_${name}"],
          var.harness_platform_variables[inpt_by_svc].CD.VARIABLES,
          {
            qa_infrastructure_id          = var.harness_platform_variables[inpt_by_svc].CD.ENV["QA"].infrastructure_id
            qa_kubernetes_namespace       = var.harness_platform_variables[inpt_by_svc].CD.ENV["QA"].kubernetes_namespace
            uat_service_now_connector_id  = var.harness_platform_variables[inpt_by_svc].CD.ENV["UAT"].service_now_connector_id
            uat_infrastructure_id         = var.harness_platform_variables[inpt_by_svc].CD.ENV["UAT"].infrastructure_id
            uat_kubernetes_namespace      = var.harness_platform_variables[inpt_by_svc].CD.ENV["UAT"].kubernetes_namespace
            prod_service_now_connector_id = var.harness_platform_variables[inpt_by_svc].CD.ENV["PRO"].service_now_connector_id
            prod_infrastructure_id        = var.harness_platform_variables[inpt_by_svc].CD.ENV["PRO"].infrastructure_id
            prod_kubernetes_namespace     = var.harness_platform_variables[inpt_by_svc].CD.ENV["PRO"].kubernetes_namespace
          }
        )
      if v.enable && "ALL" == details.env_type }
  if details.enable && details.type == "CD"])...)

  CD_ALL_inputsets = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      [for inpt_by_svc, v in details.services :
        { for inpt_by_trg, enable in v.triggers : "${inpt_by_svc}_${name}_ALL_${inpt_by_trg}" =>
          {
            vars = merge(
              local.inputset_all_infra["${inpt_by_svc}_${name}_ALL"],
              var.harness_platform_variables[inpt_by_svc].TRIGGER[inpt_by_trg],
              {
                name       = "${inpt_by_svc}_${name}_ALL_${inpt_by_trg}"
                identifier = "${lower(replace("${inpt_by_svc}_${name}_ALL_${inpt_by_trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
              }
            )
          }
        if enable }
      if v.enable && "ALL" == details.env_type]
  if details.enable && details.type == "CD"])...)
*/
  inputsets = merge(
    local.ci_type_inputset,
    local.cd_type_inputset,
    local.cd_type_inputset_all,
    local.chain_type_inputset_all
    /* local.CI_inputsets, */
    /* local.CD_inputsets, */
    /* local.CD_ALL_inputsets */
  )
  /*
  trigger_by_svc = merge(flatten(
    [for name, details in var.harness_platform_triggers :
      { for trg_by_svc, v in details.services : "${trg_by_svc}_${name}" =>
        merge(
          details,
          var.harness_platform_variables[trg_by_svc].CONNECTORS,
          {
            suffix      = var.suffix
            tags        = concat(try(details.v.tags, []), var.tags)
            org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
            project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
            yaml        = details.yaml
          }
        )
      if v.enable }
  if details.enable && details.type == "TRIGGER"])...)

  triggers = merge(flatten(
    [for name, details in var.harness_platform_triggers :
      [for trg_by_svc, v in details.services :
        { for trg, val in v.triggers : "${trg_by_svc}_${name}_${trg}" =>
          {
            vars = merge(
              local.trigger_by_svc["${trg_by_svc}_${name}"],
              {
                name       = "${trg_by_svc}_${name}_${trg}"
                identifier = "${lower(replace("${trg_by_svc}_${name}_${trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
                inputset_ids = flatten(
                  [for inpt, values in harness_platform_input_set.inputset :
                    [for trg_by_inpt, enable in val.inputsets : values.identifier
                      if enable && lower(inpt) == lower(try("${trg_by_svc}_${name}_${trg_by_inpt}", ""))
                    ]
                  ],
                )
              },
              try(val.values, {})
            )
          }
        if val.enable }
      if v.enable]
  if details.enable && details.type == "TRIGGER"])...) */

  triggers = merge(
    local.ci_type_trigger,
    local.cd_type_trigger,
    local.cd_type_trigger_all,
    local.chain_type_trigger_all
  )

  ############################################################################################
  ############################################################################################
  ############################################################################################
  ############################################################################################


  /* inputset_by_svc = merge(flatten(
    [for name, details in var.harness_platform_inputsets :
      { for inpt_by_svc, v in details.services : "${inpt_by_svc}_${name}" =>
        merge(
          details,
          var.harness_platform_variables[inpt_by_svc].CONNECTORS,
          var.harness_platform_variables[inpt_by_svc].CI,
          {
            suffix      = var.suffix
            tags        = concat(try(details.v.tags, []), var.tags)
            org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
            project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
            yaml        = details.yaml
            git_details = try(details.v.git_details, {})
            service_id  = "${replace(var.harness_platform_variables[inpt_by_svc].CI.DOCKER_IMAGE_NAME, "-", "_")}_${var.suffix}"
          }
        )
      if v.enable }
  if details.enable])...) */

  /* trigger_inpt_id = merge({ for trigger, values in local.trigger_pipe_id : trigger => flatten([for inpt, details in harness_platform_input_set.inputset : [for name, v in values.inputsets : details.identifier if lower(inpt) == lower(try(name, ""))]]) }) */
  /* trigger_org_id = merge([for trigger, values in var.harness_platform_triggers : { for org, details in var.organizations : trigger => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  trigger_prj_id = merge([for trigger, values in var.harness_platform_triggers : { for prj, details in var.projects : trigger => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)
  trigger_pipe_id = merge(flatten([for trigger, values in var.harness_platform_triggers : [for trg_by_pipe, v in values.vars.pipeline : { for pipe, details in harness_platform_pipeline.pipeline : "${trigger}_${trg_by_pipe}" =>
    {
      pipeline_id = details.identifier
      inputsets   = values.vars.pipeline[trg_by_pipe].inputsets
      yaml        = v.yaml
    }
  if lower(pipe) == lower(try(trg_by_pipe, "")) } if v.enable] if values.enable])...)

  trigger_inpt_id = merge({ for trigger, values in local.trigger_pipe_id : trigger => flatten([for inpt, details in harness_platform_input_set.inputset : [for name, v in values.inputsets : details.identifier if lower(inpt) == lower(try(name, ""))]]) })

  triggers = merge([for name, details in var.harness_platform_triggers : { for trg_by_pipe, v in details.vars.pipeline : "${name}_${trg_by_pipe}" => {
    vars = merge(
      details.vars,
      {
        suffix       = var.suffix
        name         = "${name}_${trg_by_pipe}"
        identifier   = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags         = concat(try(details.vars.tags, []), var.tags)
        org_id       = try(local.trigger_org_id[name], "") != "" ? local.trigger_org_id[name] : try(details.org_id, var.org_id)
        project_id   = try(local.trigger_prj_id[name], "") != "" ? local.trigger_prj_id[name] : try(details.project_id, var.project_id)
        pipeline_id  = try(local.trigger_pipe_id["${name}_${trg_by_pipe}"].pipeline_id, "") != "" ? local.trigger_pipe_id["${name}_${trg_by_pipe}"].pipeline_id : try(details.pipeline_id, var.pipeline_id)
        inputset_ids = try(local.trigger_inpt_id["${name}_${trg_by_pipe}"], [])
        yaml         = try(local.trigger_pipe_id["${name}_${trg_by_pipe}"].yaml, "") != "" ? local.trigger_pipe_id["${name}_${trg_by_pipe}"].yaml : ""
      }
  ) } if v.enable } if details.enable]...)

 */




  /* trigger_pipe_id = merge([for trigger, values in var.harness_platform_triggers : { for pipe, details in harness_platform_pipeline.pipeline : trigger => details.identifier if lower(pipe) == lower(try(values.vars.pipeline, "")) }]...) */
  /* trigger_inpt_id = merge({ for trigger, values in var.harness_platform_triggers : trigger => flatten([for inpt, details in harness_platform_input_set.inputset : [for name, v in values.vars.inputsets : details.identifier if lower(inpt) == lower(try(name, ""))]]) }) */











  /* triggers = { for name, details in var.harness_platform_triggers : name => {
    vars = merge(
      details.vars,
      {
        suffix = var.suffix
        name         = "${name}"
        identifier   = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags         = concat(try(details.vars.tags, []), var.tags)
        org_id       = try(local.trigger_org_id[name], "") != "" ? local.trigger_org_id[name] : try(details.org_id, var.org_id)
        project_id   = try(local.trigger_prj_id[name], "") != "" ? local.trigger_prj_id[name] : try(details.project_id, var.project_id)
        pipeline_id  = try(local.trigger_pipe_id[name].pipeline_id, "") != "" ? local.trigger_pipe_id[name].pipeline_id : try(details.pipeline_id, var.pipeline_id)
        git_details  = try(details.vars.git_details, {})
        inputset_ids = try(local.trigger_inpt_id[name], [])
      }
  ) } if details.enable } */
}

/* output "cd_type_inputset_all" {
  value = local.cd_type_inputset_all
}
output "inputset_by_svc" {
  value = local.inputset_by_svc
}
output "test" {
  value = {
    for name, details in var.harness_platform_inputsets : name => {
      org_id      = contains(keys(local.pipeline_org_id), name)
      project_id  = contains(keys(local.pipeline_prj_id), name)
      pipeline_id = contains(keys(harness_platform_pipeline.pipeline), name)
    }
  }
} */
