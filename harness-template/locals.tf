# github templates
locals {
  template_org_id = merge([for template, values in var.harness_platform_templates : { for org, details in var.organizations : template => details.identifier if lower(org) == lower(try(values.vars.organization, "")) }]...)
  template_prj_id = merge([for template, values in var.harness_platform_templates : { for prj, details in var.projects : template => details.identifier if lower(prj) == lower(try(values.vars.project, "")) }]...)

  /* connector_id = merge([for infrastructure, values in var.harness_platform_infrastructures : { for cnt, details in var.connectors.kubernetes_connectors : infrastructure => details.identifier if lower(cnt) == lower(infrastructure) }]...) */

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
      /* {
      gitlab_connectors = {
        for k, v in details.connectors : k => var.connectors.all.gitlab_connectors[v.name].identifier if v.type == "gitlab"
      }
      artifactory_connectors = {
        for k, v in details.connectors : k => var.connectors.all.artifactory_connectors[v.name].identifier if v.type == "artifactory"
      }
      github_connectors = {
        for k, v in details.connectors : k => var.connectors.all.github_connectors[v.name].identifier if v.type == "github"
      }
      docker_connectors = {
        for k, v in details.connectors : k => var.connectors.all.docker_connectors[v.name].identifier if v.type == "docker"
      }
      gcp_connectors = {
        for k, v in details.connectors : k => var.connectors.all.gcp_connectors[v.name].identifier if v.type == "gcp"
      }
      nexus_connectors = {
        for k, v in details.connectors : k => var.connectors.all.nexus_connectors[v.name].identifier if v.type == "nexus"
      }
      service_now_connectors = {
        for k, v in details.connectors : k => var.connectors.all.service_now_connectors[v.name].identifier if v.type == "service_now"
      }
      dynatrace_connectors = {
        for k, v in details.connectors : k => var.connectors.all.dynatrace_connectors[v.name].identifier if v.type == "dynatrace"
      }
      kubernetes_connectors = {
        for k, v in details.connectors : k => var.connectors.all.kubernetes_connectors[v.name].identifier if v.type == "kubernetes"
      }
      aws_connectors = {
        for k, v in details.connectors : k => var.connectors.all.aws_connectors[v.name].identifier if v.type == "aws"
      }
      helm_connectors = {
        for k, v in details.connectors : k => var.connectors.all.helm_connectors[v.name].identifier if v.type == "helm"
      }
    } */
  ) } if details.enable }


  template_commons = { for name, details in var.harness_platform_templates : name => merge(
    details,
    {
      vars = merge(
        details.vars,
        try(details.template, {}),
        try(details.default_values, {}),
        try(local.template_connectors[name], {}),
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
          stages = {
            for k, v in try(details.template, {}) : k => {
              template_id      = "${try(v.template_level, "project") == "project" ? "" : "${v.template_level}."}${try(harness_platform_template.stage[v.template_name].identifier, "NOT_DEFINED")}"
              template_version = try(v.template_version, "1")
            } if try(v.type, "") == "stage"
          }
          template-deployment = {
            template_id      = "${try(details.template.template-deployment.template_level, "project") == "project" ? "" : "${details.template.template-deployment.template_level}."}${try(harness_platform_template.template_deployment[try(details.template.template-deployment.template_name, "NOT_DEFINED")].identifier, "NOT_DEFINED")}"
            template_version = try(details.template.template-deployment.template_version, "1")
          }
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
