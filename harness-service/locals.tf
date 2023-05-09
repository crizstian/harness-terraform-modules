locals {
  service_org_id = merge([for service, values in var.harness_platform_services : { for org, details in var.organizations : service => details.identifier if lower(org) == lower(try(values.SERVICE_DEFINITION.organization, "")) }]...)
  service_prj_id = merge([for service, values in var.harness_platform_services : { for prj, details in var.projects : service => details.identifier if lower(prj) == lower(try(values.SERVICE_DEFINITION.project, "")) }]...)
  service_tpl_dp_id = {
    for service, values in var.harness_platform_services : service => {
      template-deployment = {
        template_id      = try(var.templates.template_deployments[values.template.template-deployment.template_name].identifier, "")
        template_version = try(values.template.template-deployment.template_version, "")
      }
    }
  }

  /* service_cnt_ids = {for service, values in var.harness_platform_services: service => merge(
    [
      for cnt, value in values.CONNECTORS: {}
    ]...)
    } */

  services = { for name, details in var.harness_platform_services : name => {
    vars = merge(
      try(details.CI, {}),
      try(var.var.connectors.default_connectors, {}),
      try(details.CONNECTORS, {}),
      try(local.service_tpl_dp_id[name], {}),
      details.SERVICE_DEFINITION,
      {
        name       = "${name}"
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags       = concat(try(details.SERVICE_DEFINITION.tags, []), var.tags)
        org_id     = try(local.service_org_id[name], "") != "" ? local.service_org_id[name] : try(details.vars.org_id, var.org_id)
        project_id = try(local.service_prj_id[name], "") != "" ? local.service_prj_id[name] : try(details.vars.project_id, var.project_id)
      }
  ) } if details.SERVICE_DEFINITION.enable }
}
