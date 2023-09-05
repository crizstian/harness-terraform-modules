locals {
  steps_output = { for key, value in harness_platform_template.step : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
  step_groups_output = { for key, value in harness_platform_template.step-group : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
  stages_output = { for key, value in harness_platform_template.stage : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
  template_deployments_output = { for key, value in harness_platform_template.template_deployment : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
  pipelines_output = { for key, value in harness_platform_template.pipeline : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
  templates_output = { for key, value in harness_platform_template.template : key =>
    {
      identifier     = value.project_id != "" ? value.identifier : value.org_id != "" ? "org.${value.identifier}" : "account.${value.identifier}"
      default_values = try(var.harness_platform_templates[key].default_values, {})
    }
  }
}

output "all" {
  value = merge(
    length(keys(local.steps_output)) > 0 ? { steps = local.steps_output } : {},
    length(keys(local.step_groups_output)) > 0 ? { step_groups = local.step_groups_output } : {},
    length(keys(local.stages_output)) > 0 ? { stages = local.stages_output } : {},
    length(keys(local.template_deployments_output)) > 0 ? { template_deployments = local.template_deployments_output } : {},
    length(keys(local.pipelines_output)) > 0 ? { pipelines = local.pipelines_output } : {},
    length(keys(local.templates_output)) > 0 ? { templates = local.templates_output } : {},
  )
}

output "test" {
  value = local.template_connectors
}
