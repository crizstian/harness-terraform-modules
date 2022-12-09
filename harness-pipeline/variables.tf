variable "suffix" {}
variable "tags" {
  default = []
}
variable "harness_platform_pipelines" {
  description = "Harness Pipelines to be created in the given Harness account"
  default     = {}
}

variable "harness_platform_inputsets" {
  description = "Harness Inputsets to be created in the given Harness account"
  default     = {}
}

locals {
  pipeline_templates = { for name, details in var.harness_platform_pipelines : name => merge(
    details.pipeline,
    {
      tags       = concat(details.pipeline.vars.tags, var.tags)
      identifier = "${lower(replace(name, "-", "_"))}_${var.suffix}"
    })
  }

  inputset_templates = merge([for name, details in var.harness_platform_pipelines : {
    for key, value in var.harness_platform_pipelines[name].inputset : "${name}_inputset_${key}" =>
    merge(
      value,
      {
        identifier = "${lower(replace(name, "-", "_"))}_inputset_${lower(replace(key, "-", "_"))}_${var.suffix}"
        vars       = merge(details.pipeline.vars, value.vars, { pipeline_id = harness_platform_pipeline.pipeline[name].identifier })
      }
    ) }
  ]...)

  trigger_templates = merge([for name, details in var.harness_platform_pipelines : {
    for key, value in var.harness_platform_pipelines[name].trigger : "${name}_trigger_${key}" =>
    merge(
      value,
      {
        identifier = "${lower(replace(name, "-", "_"))}_trigger_${lower(replace(key, "-", "_"))}_${var.suffix}"
        vars = merge(
          details.pipeline.vars,
          details.inputset[value.inputset_ref].vars, value.vars,
          {
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
            enabled     = details.enable
          }
        )
      }
    ) }
  ]...)
}

# locals {
#   # pipeline_non_templatized = { for name, details in var.harness_platform_pipelines : name => details
#   #   if !can(details.custom_template.pipeline)
#   # }

#   # all_pipelines = merge(local.pipeline_rendered, local.pipeline_non_templatized)

#   # pipelines = { for name, details in local.all_pipelines : name => details }
# }
