# github pipelines
locals {

  pipeline_org_id = merge([for pipeline, values in var.harness_platform_pipelines : { for org, details in var.organizations : pipeline => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  pipeline_prj_id = merge([for pipeline, values in var.harness_platform_pipelines : { for prj, details in var.projects : pipeline => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  /* connector_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in var.connectors.kubernetes_connectors : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...) */

  templates = {}

  pipeline_tpl_id = { for pipeline, values in var.harness_platform_pipelines : pipeline =>
    merge(
      {
        for k, v in try(values.template, {}) : k =>
        {
          template_id      = try(var.templates.stages[v.template_name].identifier, "NOT_DEFINED")
          template_version = try(v.template_version, "NOT_DEFINED")
        } if v.type == "stage"
      },
      {
        for k, v in try(values.template, {}) : k =>
        {
          template_id      = try(var.templates.pipelines[v.template_name].identifier, "NOT_DEFINED")
          template_version = try(v.template_version, "NOT_DEFINED")
        } if v.type == "pipeline"
      }
    ) if values.enable
  }

  pipeline_tpl_default_values = { for pipeline, values in var.harness_platform_pipelines : pipeline =>
    merge(merge(
      concat(
        [
          for k, v in try(values.template, {}) : try(var.templates.stages[v.template_name].default_values, {}) if v.type == "stage"
        ],
        [
          for k, v in try(values.template, {}) : try(var.templates.pipelines[v.template_name].default_values, {}) if v.type == "pipeline"
        ]
      )...
      ),
      try(values.default_values, {})
    )
  }

  /* pipeline_env = {
    for pipeline, values in var.harness_platform_pipelines : pipeline => [
      for env, infra in values.environment : merge(
        infra,
        local.inpt_by_svc["${svc}_${name}_${inpt}"],
        {
          env               = "${env}"
          env_id            = var.environments[env].identifier
          infrastructure_id = var.infrastructures[infra.infrastructure].identifier
        }
      )
    ]
  } */

  pipelines = { for name, details in var.harness_platform_pipelines : name => {
    default_values = try(local.pipeline_tpl_default_values[name], {})
    vars = merge(
      details.vars,
      try(local.pipeline_tpl_id[name], {}),
      try(local.pipeline_tpl_default_values[name], {}),
      try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
      {
        suffix      = var.suffix
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.common_values.project_id)
        git_details = try(details.vars.git_details, {})
        /* template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) */
      }
  ) } if details.enable && details.type == "pipeline" }



  chained_pipelines = { for name, details in var.harness_platform_pipelines : name => {
    default_values = try(local.pipeline_tpl_default_values[name], {})
    vars = merge(
      details.vars,
      merge([for temp, values in details.template : merge(
        try(var.templates.stages[values.name].default_values, try(var.templates.pipelines[values.name].default_values, {})),
      )]...),
      try(local.pipeline_tpl_id[name], {}),
      try(local.pipeline_tpl_default_values[name], {}),
      try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
      {
        for temp, values in details.template : temp =>
        {
          template_id = harness_platform_pipeline.pipeline[values.template_name].identifier
          version     = values.template_version
        } if values.type == "chain"
      },
      {
        suffix      = var.suffix
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.common_values.org_id)
        project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.common_values.project_id)
        git_details = try(details.vars.git_details, {})

        /* template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) */
      }
  ) } if details.enable && details.type == "chained-pipeline" }
}
