# github pipelines
locals {

  /* services = {
    for svc, details in var.services : svc => merge(
      var.harness_platform_service_configs[details.SERVICE_DEFINITION.type],
      details.SERVICE_DEFINITION,
      try(var.harness_platform_service_configs[details.SERVICE_DEFINITION.type].CONNECTORS, {}),
      {
        "${details.SERVICE_DEFINITION.type}_service_id" = "${lower(replace(svc, "/[\\s-.]/", "_"))}_${var.suffix}"
      }
    )
  } */

  inpt_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : {
        for pipe, values in variables.vars.PIPELINE : "${svc}_${name}" =>
        merge(
          try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
          try(var.templates.pipelines[pipe].default_values, {}),
          try(var.connectors.default_connectors, {}),
          try(var.pipelines[pipe].default_values, {}),
          try(details.default_values, {}),
          variables,
          {
            svc         = "${svc}"
            suffix      = var.suffix
            tags        = concat(try(variables.vars.tags, []), var.tags)
            git_details = try(variables.vars.git_details, {})
            org_id      = var.pipelines[pipe].org_id
            project_id  = var.pipelines[pipe].project_id
            pipeline_id = var.pipelines[pipe].identifier
          },
          details
        ) if values.INPUTSET && try(details.pipeline, name) == pipe
      } if variables.vars.enable
    ] if details.enable
  ])...)

  ci = { for name, values in local.inpt_by_svc : name =>
    {
      vars = merge(
        values,
        {
          name       = lower(replace(name, "/[\\s-.]/", "_"))
          identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        }
      )
    } if values.type == "CI"
  }

  inpt = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" =>
            {
              vars = merge(
                local.inpt_by_svc["${svc}_${name}"],
                {
                  env                                        = "${env}"
                  env_id                                     = env_details.identifier
                  primary_artifact                           = env_details.primary_artifact
                  delegate_selectors                         = try(infra_details.delegate_selectors, ["NOT_DEFINED"])
                  name                                       = replace("${svc}_${infra}", "${variables.vars.type}_", "")
                  identifier                                 = "${lower(replace(replace("${svc}_${infra}", "/[\\s-.]/", "_"), "${variables.vars.type}_", ""))}_${var.suffix}"
                  "${variables.vars.type}_infrastructure_id" = infra_details.identifier
                }
              )
            } if infra_details.env_id == env_details.identifier
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact)
        ] if try(details.pipeline, name) == pipe && values.INPUTSET
      ] if variables.vars.enable
    ] if details.enable && details.type == "CD"
  ])...)


  inpt_by_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && !can(variables.vars.settings.infrastructure)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && !can(variables.vars.settings.pipelines)
      ] if variables.vars.enable && !can(variables.vars.settings.inputsets)
    ] if details.enable && details.type == "CD"
  ])...)

  inpt_by_inputset_specific = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && !can(variables.vars.settings.infrastructure)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && !can(variables.vars.settings.pipelines)
      ] if variables.vars.enable && try(variables.vars.vars.settings.inputsets[name], false)
    ] if details.enable && details.type == "CD"
  ])...)

  inpt_by_infra_specific = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && try(variables.vars.vars.settings.infrastructure[replace(infra, "${variables.vars.type}_", "")], false)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && !can(variables.vars.settings.pipelines)
      ] if variables.vars.enable && !can(variables.vars.settings.inputsets)
    ] if details.enable && details.type == "CD"
  ])...)



  inpt_by_pipeline_specific = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && !can(variables.vars.settings.infrastructure)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && try(variables.vars.vars.settings.pipelines[try(details.pipeline, name)], false)
      ] if variables.vars.enable && !can(variables.vars.settings.inputsets)
    ] if details.enable && details.type == "CD"
  ])...)


  inpt_by_infra_and_pipeline_specific = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && try(variables.vars.vars.settings.infrastructure[replace(infra, "${variables.vars.type}_", "")], false)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && try(variables.vars.vars.settings.pipelines[try(details.pipeline, name)], false)
      ] if variables.vars.enable && !can(variables.vars.settings.inputsets)
    ] if details.enable && details.type == "CD"
  ])...)

  inpt_by_infra_and_pipeline_and_input_specific = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : [

        for pipe, values in variables.vars.PIPELINE : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" => local.inpt["${svc}_${name}_${env}_${infra}"]

            if infra_details.env_id == env_details.identifier && try(variables.vars.vars.settings.infrastructure[replace(infra, "${variables.vars.type}_", "")], false)
          } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && !can(variables.vars.settings.environments) #&& try(local.inpt_by_svc["${svc}_${name}"].environment_type, env_details.type) == env_details.type
        ] if try(details.pipeline, name) == pipe && values.INPUTSET && try(variables.vars.vars.settings.pipelines[try(details.pipeline, name)], false)
      ] if variables.vars.enable && try(variables.vars.vars.settings.inputsets[name], false)
    ] if details.enable && details.type == "CD"
  ])...)


  inpt_by_all_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : {
        for pipe, values in variables.vars.PIPELINE : "${svc}_${name}_ALL" => {
          vars = merge(
            local.inpt_by_svc["${svc}_${name}"],
            {
              name       = "${svc}"
              identifier = "${lower(replace("${svc}_${name}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
            },
            flatten([for env, env_details in var.environments : [
              for infra, infra_details in var.infrastructures : {
                "${variables.vars.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
              } if infra_details.env_id == env_details.identifier
            ]])...
          )
        } if try(details.pipeline, name) == pipe && values.INPUTSET
      } if variables.vars.enable && !can(variables.vars.settings.infrastructure)
    ] if details.enable && details.type == "ALL" && !can(details.vars.base_env)
  ])...)

  inpt_by_base_env = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.services : {
        for pipe, values in variables.vars.PIPELINE : "${svc}_${name}_ALL" => {
          vars = merge(
            local.inpt_by_svc["${svc}_${name}"],
            {
              name       = "${svc}"
              identifier = "${lower(replace("${svc}_${name}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
            },
            flatten([for env, env_details in var.environments : [
              for infra, infra_details in var.infrastructures : {
                "${variables.vars.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
              } if infra_details.env_id == env_details.identifier && details.vars.base_env == env
            ]])...
          )
        } if try(details.pipeline, name) == pipe && values.INPUTSET
      } if variables.vars.enable && !can(variables.vars.settings.infrastructure)
    ] if details.enable && details.type == "ALL" && can(details.vars.base_env)
  ])...)


  inputsets = merge(
    /* local.ci, */
    local.inpt_by_infra,
    local.inpt_by_infra_specific,
    local.inpt_by_inputset_specific,
    local.inpt_by_pipeline_specific,
    local.inpt_by_infra_and_pipeline_specific,
    local.inpt_by_infra_and_pipeline_and_input_specific,
    local.inpt_by_all_infra,
    local.inpt_by_base_env,
  )
}
