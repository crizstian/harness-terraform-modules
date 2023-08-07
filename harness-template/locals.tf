# github templates
locals {
  template_org_id = merge([for template, values in var.harness_platform_templates : { for org, details in var.organizations : template => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  template_prj_id = merge([for template, values in var.harness_platform_templates : { for prj, details in var.projects : template => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  template_connectors = { for name, details in var.harness_platform_templates : name => {
    connector = merge(
      flatten([
        for type, connectors in var.connectors : {
          for tipo, connector in try(details.connector, {}) : tipo => {
            for key, value in connector : key => {
              connector_id = connectors[value.name].identifier
            }
          } if "${tipo}_connectors" == type
        }
      ])...
  ) } if details.enable }


  template_commons = { for name, details in var.harness_platform_templates : name => merge(
    details,
    {
      vars = merge(
        details.vars,
        try(details.template, {}),
        try(details.default_values, {}),
        try(local.template_connectors[name], {}),
        try(details.vars.usergroups_required, false) ? { usergroups = var.usergroups } : {},
        {
          name        = "${name}"
          identifier  = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
          description = details.vars.description
          tags        = concat(try(details.vars.tags, []), var.tags)
          org_id      = try(local.template_org_id[name], "") != "" ? local.template_org_id[name] : try(details.org_id, var.org_id)
          project_id  = try(local.template_prj_id[name], "") != "" ? local.template_prj_id[name] : try(details.project_id, var.project_id)
          git_details = try(details.vars.git_details, {})
        }
      )
    }
  ) if details.enable }


  steps               = { for name, details in local.template_commons : name => details if details.type == "step" }
  template_deployment = { for name, details in local.template_commons : name => details if details.type == "template-deployment" }
  definitions         = { for name, details in local.template_commons : name => details if details.type != "step" && details.type != "step-group" && details.type != "stage" && details.type != "template-deployment" && details.type != "pipeline" }

  step_groups = { for name, details in local.template_commons : name => {
    vars = merge(
      details.vars,
      {
        step = {
          for k, v in details.template : k => {
            template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.step[v.template_name].identifier, "NOT_DEFINED")}"
            template_version = try(v.template_version, "1")
          } if try(v.type, "") == "step"
        }
      }
    )
    } if details.type == "step-group"
  }

  stages = {
    for name, details in local.template_commons : name => {
      vars = merge(
        details.vars,
        {
          step = {
            for k, v in try(details.template, {}) : k => {
              template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.step[v.template_name].identifier, "NOT_DEFINED")}"
              template_version = try(v.template_version, "1")
            } if try(v.type, "") == "step"
          }
          step_group = {
            for k, v in try(details.template, {}) : k => {
              template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.step-group[v.template_name].identifier, "NOT_DEFINED")}"
              template_version = try(v.template_version, "1")
            } if try(v.type, "") == "step-group"
          }
      })
    }
    if details.type == "stage"
  }

  pipelines = {
    for name, details in local.template_commons : name => {
      vars = merge(
        details.vars,
        {
          for k, v in try(details.template, {}) : k => {
            template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.step[v.template_name].identifier, "NOT_DEFINED")}"
            template_version = try(v.template_version, "1")
          } if try(v.type, "") == "step"
        },
        {
          for k, v in try(details.template, {}) : k => {
            template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.step-group[v.template_name].identifier, "NOT_DEFINED")}"
            template_version = try(v.template_version, "1")
          } if try(v.type, "") == "step-group"
        },
        {
          for k, v in try(details.template, {}) : k => {
            template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.stage[v.template_name].identifier, "NOT_DEFINED")}"
            template_version = try(v.template_version, "1")
          } if try(v.type, "") == "stage"
        },
        {
          for k, v in try(details.template, {}) : k => {
            template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.template_deployment[v.template_name].identifier, "NOT_DEFINED")}"
            template_version = try(v.template_version, "1")
          } if try(v.type, "") == "template-deployment"
        },
        {
          sto = {
            template_id      = "${try(details.template.sto.template_level, "project") == "project" ? "" : "${details.template.sto.template_level}."}${try(harness_platform_template.stage[try(details.template.sto.template_name, "NOT_DEFINED")].identifier, "NOT_DEFINED")}"
            template_version = try(details.template.sto.template_version, "1")
          }
      })
    }
    if details.type == "pipeline"
  }
}

output "template_commons" {
  value = local.template_commons
}
