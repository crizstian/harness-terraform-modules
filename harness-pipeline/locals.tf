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
      try(var.templates.stages[details.template.pipeline.template_name].default_values, try(var.templates.pipelines[details.template.pipeline.template_name].default_values, {})),
      {
        suffix      = var.suffix
        name        = "${name}"
        identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags        = concat(try(details.vars.tags, []), var.tags)
        org_id      = try(local.pipeline_org_id[name], "") != "" ? local.pipeline_org_id[name] : try(details.org_id, var.org_id)
        project_id  = try(local.pipeline_prj_id[name], "") != "" ? local.pipeline_prj_id[name] : try(details.project_id, var.project_id)
        git_details = try(details.vars.git_details, {})
        /* template_variables = try(yamldecode(data.harness_platform_template.template[name].template_yaml).template.spec.variables, {}) */
      }
  ) } if details.enable && details.type == "pipeline" }
}
