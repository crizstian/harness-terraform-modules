# github pipelines
locals {
  inputsets                  = var.inputsets.inputset
  inputsets_verbose          = var.inputsets.verbose
  inputsets_verbose_by_infra = var.inputsets.verbose_by_infra

  trg_by_svc = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.services : [
        for pipe, values in variables.vars.PIPELINE : {
          for trg, enable in try(values.TRIGGER, {}) : "${svc}_${name}_${trg}" =>
          merge(
            try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
            try(var.templates.pipelines[pipe].default_values, {}),
            try(var.connectors.default_connectors, {}),
            try(var.pipelines[pipe].default_values, {}),
            try(details.default_values, {}),
            variables.vars,
            try(variables.vars.default_values, {}),
            {
              trg                                 = "${trg}"
              svc                                 = "${svc}"
              suffix                              = var.suffix
              tags                                = [] #concat(try(variables.vars.tags, []), var.tags)
              git_details                         = try(variables.vars.git_details, {})
              org_id                              = var.pipelines[pipe].org_id
              project_id                          = var.pipelines[pipe].project_id
              pipeline_id                         = var.pipelines[pipe].identifier
              service_type                        = variables.vars.type
              "${variables.vars.type}_service_id" = "${lower(replace(svc, "/[\\s-.]/", "_"))}_${var.suffix}"
            },
            details
          ) if enable && try(details.pipeline, name) == pipe
        } #if variables.vars.enable
      ]
    ] if details.enable
  ])...)

  ci = { for name, values in local.trg_by_svc : name =>
    {
      vars = merge(
        try(local.inputsets_verbose["${values.svc}_${values.name}"], {}),
        values,
        {
          name       = "${values.svc}_${values.trg}"
          identifier = "${lower(replace("${values.svc}_${values.trg}", "/[\\s-.]/", "_"))}_${var.suffix}"
          /* inputset_ids = try([for inpt, enable in values.TRIGGER_INPUTSET : local.inputsets["${values.svc}_${values.name}"].identifier if enable], ["NOT_DEFINED"]) */
        }
      )
    } if values.type == "CI"
  }

  trg_by_infra = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.services : [
        for pipe, values in variables.vars.PIPELINE : [
          for trg, enable in try(values.TRIGGER, {}) : [
            for env, env_details in var.environments : {
              for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}_${trg}" =>
              {
                vars = merge(
                  local.trg_by_svc["${svc}_${name}_${trg}"],
                  {
                    env                                        = "${env}"
                    env_id                                     = env_details.identifier
                    primary_artifact                           = env_details.primary_artifact
                    trigger_artifact_regex                     = try(env_details.trigger_artifact_regex, "")
                    delegate_selectors                         = try(infra_details.delegate_selectors, ["NOT_DEFINED"])
                    name                                       = replace("${svc}_${infra}_${trg}", "${variables.vars.type}_", "")
                    identifier                                 = "${lower(replace(replace("${svc}_${infra}_${trg}", "/[\\s-.]/", "_"), "${variables.vars.type}_", ""))}_${var.suffix}"
                    "${variables.vars.type}_infrastructure_id" = infra_details.identifier
                  }
                )
              } if infra_details.env_id == env_details.identifier
            } if contains(keys(variables.vars.artifacts), env_details.primary_artifact) && try(var.pipelines[pipe].default_values.environment_type, "NONE") == env_details.type
          ] if enable
        ] if try(details.pipeline, name) == pipe
      ]
    ] if details.enable && details.type == "CD"
  ])...)

  /* trg_by_infra = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.services : [
        for pipe, values in try(variables.PIPELINE, {}) : [
          for trg, enable in try(values.TRIGGER, {}) : [
            for env, env_details in var.environments : {
              for infra, infra_details in var.infrastructures : "${svc}_${name}_${trg}_${env}_${infra}" =>
              {
                vars = merge(
                  local.trg_by_svc["${svc}_${name}_${trg}"],
                  try(local.inputsets_verbose_by_infra["${svc}_${name}_${trg}_${env}"], {}),
                  {
                    env                                        = "${env}"
                    env_id                                     = env_details.identifier
                    "${variables.vars.type}_infrastructure_id" = infra_details.identifier
                    delegate_selectors                         = try(infra_details.delegate_selectors, ["NOT_DEFINED"])
                    primary_artifact                           = env_details.primary_artifact
                    trigger_artifact_regex                     = try(env_details.trigger_artifact_regex, "")
                    name                                       = replace("${svc}_${infra}", "kubernetes_", "")
                    identifier                                 = "${lower(replace(replace("${svc}_${infra}", "/[\\s-.]/", "_"), "kubernetes_", ""))}_${var.suffix}"
                  }
                )
              } if infra_details.env_id == env_details.identifier
            } if contains(keys(variables.vars.artifacts), env_details.primary_artifact)
          ] if enable

        ] if name == pipe
      ] if variables.vars.enable
    ] if details.enable && details.type == "CD"
  ])...) */

  trg_by_all_infra = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.services : [
        for pipe, values in variables.vars.PIPELINE : {
          for trg, enable in try(values.TRIGGER, {}) : "${svc}_${name}_${trg}" =>
          {
            vars = merge(
              local.trg_by_svc["${svc}_${name}_${trg}"],
              {
                name       = "${svc}"
                identifier = "${lower(replace("${svc}", "/[\\s-.]/", "_"))}_${var.suffix}"
                /* inputset_ids = try([for inpt, enable in definition.TRIGGER_INPUTSET : local.inputsets["${svc}_${name}_${inpt}_${trg}"].identifier if enable], ["NOT_DEFINED"]) */
              },
              /* try(local.inputsets_verbose_by_infra["${svc}_${name}"], {}), */
              flatten([for env, env_details in var.environments : [
                for infra, infra_details in var.infrastructures : {
                  "${variables.vars.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
                } if infra_details.env_id == env_details.identifier
              ]])...
            )
          } if enable
        } if try(details.pipeline, name) == pipe
      ] # if contains(keys(variables.vars.artifacts), try(details.vars.type, "NONE"))
    ] if details.enable && details.type == "ALL" && !can(details.vars.base_env)
  ])...)

  simple_trg_by_all_infra = merge(flatten({
    for name, details in var.harness_platform_triggers : "" => {
      vars = merge(
        {
          "name"     = name
          identifier = "${lower(replace("${name}", "/[\\s-.]/", "_"))}"
          /* inputset_ids = try([for inpt, enable in definition.TRIGGER_INPUTSET : local.inputsets["${svc}_${name}_${inpt}_${trg}"].identifier if enable], ["NOT_DEFINED"]) */
        },
        /* try(local.inputsets_verbose_by_infra["${svc}_${name}"], {}), */
        flatten([for env, env_details in var.environments : [
          for infra, infra_details in var.infrastructures : {
            "${variables.vars.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
          } if infra_details.env_id == env_details.identifier
        ]])...
      )
    } if details.enable && details.type == "SIMPLE_ALL" && !can(details.vars.base_env)
  })...)

  inpt_by_base_env = merge(flatten([
    for name, details in var.harness_platform_triggers : [
      for svc, variables in var.services : [
        for pipe, values in variables.vars.PIPELINE : {
          for trg, enable in try(values.TRIGGER, {}) : "${svc}_${name}_${trg}" =>
          {
            vars = merge(
              local.trg_by_svc["${svc}_${name}_${trg}"],
              {
                name       = "${svc}"
                identifier = "${lower(replace("${svc}", "/[\\s-.]/", "_"))}_${var.suffix}"
                /* inputset_ids = try([for inpt, enable in definition.TRIGGER_INPUTSET : local.inputsets["${svc}_${name}_${inpt}_${trg}"].identifier if enable], ["NOT_DEFINED"]) */
              },
              /* try(local.inputsets_verbose_by_infra["${svc}_${name}"], {}), */
              flatten([for env, env_details in var.environments : [
                for infra, infra_details in var.infrastructures : {
                  env_id                                     = env_details.identifier
                  "${variables.vars.type}_infrastructure_id" = infra_details.identifier
                } if infra_details.env_id == env_details.identifier && details.vars.base_env == env
              ]])...
            )
          } if enable
        } if try(details.pipeline, name) == pipe
      ] #if contains(keys(variables.vars.artifacts), try(details.vars.type, "NONE"))
    ] if details.enable && details.type == "ALL" && can(details.vars.base_env)
  ])...)


  triggers = merge(
    local.ci,
    local.trg_by_infra,
    local.trg_by_all_infra,
    local.inpt_by_base_env,
    local.simple_trg_by_all_infra
  )
}
