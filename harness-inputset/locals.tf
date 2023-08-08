# github pipelines
locals {

  /* inpt_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in try(variables.PIPELINE, {}) : {
          for inpt, set in try(values.INPUTSET, {}) : "${svc}_${name}_${inpt}" =>
          merge(
            try(var.templates.stages[name].default_values, try(var.templates.pipelines[pipe].default_values, {})),
            try(var.connectors.default_connectors, {}),
            try(variables.CONNECTORS, {}),
            try(variables.CI, {}),
            try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
            details,
            var.pipelines[pipe].default_values,
            set.VALUES,
            {
              svc                                               = "${svc}"
              inpt                                              = "${inpt}"
              suffix                                            = var.suffix
              tags                                              = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
              git_details                                       = try(variables.SERVICE_DEFINITION.git_details, {})
              "${variables.SERVICE_DEFINITION.type}_service_id" = try("${replace(svc, "-", "_")}_${var.suffix}", "")
              org_id                                            = try(var.pipelines[pipe].org_id, "") != "" ? var.pipelines[pipe].org_id : try(details.org_id, var.org_id)
              project_id                                        = try(var.pipelines[pipe].project_id, "") != "" ? var.pipelines[pipe].project_id : try(details.project_id, var.project_id)
              pipeline_id                                       = try(var.pipelines[pipe].identifier, "")
            }
          ) if try(set.enable, false) && name == pipe
        } #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable
  ])...) */

  inpt_by_svc = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for pipe, values in try(variables.PIPELINE, {}) : "${svc}_${name}" =>
        merge(
          try(var.templates.stages[name].default_values, try(var.templates.pipelines[pipe].default_values, {})),
          try(var.connectors.default_connectors, {}),
          try(variables.CONNECTORS, {}),
          try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
          details,
          var.pipelines[pipe].default_values,
          {
            svc                                               = "${svc}"
            suffix                                            = var.suffix
            tags                                              = concat(try(variables.SERVICE_DEFINITION.tags, []), var.tags)
            git_details                                       = try(variables.SERVICE_DEFINITION.git_details, {})
            "${variables.SERVICE_DEFINITION.type}_service_id" = try("${replace(svc, "-", "_")}_${var.suffix}", "")
            org_id                                            = try(var.pipelines[pipe].org_id, "") != "" ? var.pipelines[pipe].org_id : try(details.org_id, var.org_id)
            project_id                                        = try(var.pipelines[pipe].project_id, "") != "" ? var.pipelines[pipe].project_id : try(details.project_id, var.project_id)
            pipeline_id                                       = try(var.pipelines[pipe].identifier, "")
          }
        )
      } if variables.SERVICE_DEFINITION.enable && values.INPUSET
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

  inpt_by_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [

        for pipe, values in try(variables.PIPELINE, {}) : [
          for env, env_details in var.environments : {
            for infra, infra_details in var.infrastructures : "${svc}_${name}_${env}_${infra}" =>
            {
              vars = merge(
                local.inpt_by_svc["${svc}_${name}"],
                {
                  env                                                      = "${env}"
                  env_id                                                   = env_details.identifier
                  "${variables.SERVICE_DEFINITION.type}_infrastructure_id" = infra_details.identifier
                  delegate_selectors                                       = try(infra_details.delegate_selectors, ["NOT_DEFINED"])
                  name                                                     = replace("${svc}_${infra}", "kubernetes_", "")
                  identifier                                               = "${lower(replace(replace("${svc}_${infra}", "/[\\s-.]/", "_"), "kubernetes_", ""))}_${var.suffix}"
                }
              )
            } if infra_details.env_id == env_details.identifier
          }
        ] if name == pipe && values.INPUSET
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "CD"
  ])...)

  /* inpt_by_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [

        for pipe, values in try(variables.PIPELINE, {}) : [
          for inpt, set in try(values.INPUTSET, {}) : [

            for env, env_details in var.environments : {
              for infra, infra_details in var.infrastructures : "${svc}_${name}_${inpt}_${env}_${infra}" =>
              {
                vars = merge(
                  local.inpt_by_svc["${svc}_${name}_${inpt}"],
                  {
                    env                                                      = "${env}"
                    env_id                                                   = env_details.identifier
                    "${variables.SERVICE_DEFINITION.type}_infrastructure_id" = infra_details.identifier
                    delegate_selectors                                       = try(infra_details.delegate_selectors, ["NOT_DEFINED"])
                    name                                                     = replace("${svc}_${infra}", "kubernetes_", "")
                    identifier                                               = "${lower(replace(replace("${svc}_${infra}", "/[\\s-.]/", "_"), "kubernetes_", ""))}_${var.suffix}"
                  }
                )
              } if infra_details.env_id == env_details.identifier
            }

          ] if try(set.enable, false) && name == pipe
        ] #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "CD"
  ])...) */

  inpt_by_all_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : {
        for pipe, values in try(variables.PIPELINE, {}) : "${svc}_${name}_${inpt}_ALL" => {
          vars = merge(
            local.inpt_by_svc["${svc}_${name}"],
            {
              name       = "${svc}"
              identifier = "${lower(replace("${svc}_${name}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
            },
            flatten([for env, env_details in var.environments : [
              for infra, infra_details in var.infrastructures : {
                "${variables.SERVICE_DEFINITION.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
              } if infra_details.env_id == env_details.identifier
            ]])...
          )
        } if name == pipe && values.INPUSET
      } if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "ALL"
  ])...)

  /* inpt_by_all_infra = merge(flatten([
    for name, details in var.harness_platform_inputsets : [
      for svc, variables in var.harness_platform_services : [
        for pipe, values in try(variables.PIPELINE, {}) : {
          for inpt, set in try(values.INPUTSET, {}) : "${svc}_${name}_${inpt}_ALL" => {
            vars = merge(
              local.inpt_by_svc["${svc}_${name}_${inpt}"],
              {
                name       = "${svc}"
                identifier = "${lower(replace("${svc}_${name}_${inpt}_ALL", "/[\\s-.]/", "_"))}_${var.suffix}"
              },
              flatten([for env, env_details in var.environments : [
                for infra, infra_details in var.infrastructures : {
                  "${variables.SERVICE_DEFINITION.type}_${lower(env)}_infrastructure_id" = infra_details.identifier
                } if infra_details.env_id == env_details.identifier
              ]])...
            )
          } if try(set.enable, false) && name == pipe
        } #if values.enable
      ] if variables.SERVICE_DEFINITION.enable
    ] if details.enable && details.type == "ALL"
  ])...) */

  inputsets = merge(
    local.ci,
    local.inpt_by_infra,
    local.inpt_by_all_infra,
  )
}
