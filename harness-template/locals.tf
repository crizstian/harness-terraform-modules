# github templates
locals {
  template_org_id = merge([for template, values in var.harness_platform_templates : { for org, details in var.organizations : template => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  template_prj_id = merge([for template, values in var.harness_platform_templates : { for prj, details in var.projects : template => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  /* connector_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in var.connectors.kubernetes_connectors : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...) */

  template_commons = { for name, details in var.harness_platform_templates : name => merge(
    details,
    {
      vars = merge(
        details.vars,
        try(details.template, {}),
        try(details.default_values, {}),
        {
          name        = "${name}"
          identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
          description = details.vars.description
          tags        = concat(try(details.vars.tags, []), var.tags)
          org_id      = try(local.template_org_id[name], "") != "" ? local.template_org_id[name] : try(details.org_id, var.org_id)
          project_id  = try(local.template_prj_id[name], "") != "" ? local.template_prj_id[name] : try(details.project_id, var.project_id)
          git_details = try(details.vars.git_details, {})
        }
    ) }
  ) if details.enable }

  steps               = { for name, details in local.template_commons : name => details if details.type == "step" }
  stages              = { for name, details in local.template_commons : name => details if details.type == "stage" }
  template_deployment = { for name, details in local.template_commons : name => details if details.type == "template-deployment" }
  definitions         = { for name, details in local.template_commons : name => details if details.type != "step" && details.type != "stage" && details.type != "template-deployment" && details.type != "pipeline" }

  pipelines = {
    for name, details in local.template_commons : name => {
      vars = merge(
        details.vars,
        {
          steps  = {}
          stages = {}
          template-deployment = {
            template_id      = "${try(details.template.template-deployment.template_level, "project") == "project" ? "" : "${details.template.template-deployment.template_level}."}${try(harness_platform_template.template_deployment[try(details.template.template-deployment.template_name, "null")].identifier, "null")}"
            template_version = try(details.template.template-deployment.template_version, "1")
          }
      })
    }
    if details.type == "pipeline"
  }
}

output "template_commons" {
  value = local.template_commons
}
