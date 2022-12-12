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
      tags = concat(details.pipeline.vars.tags, var.tags)
      vars = merge(
        details.pipeline.vars,
        {
          identifier  = "${lower(replace(name, "-", "_"))}_${var.suffix}"
          description = details.pipeline.description
      })
    })
  }

  inputset_templates = merge([for name, details in var.harness_platform_pipelines : {
    for key, value in details.inputset : "${key}_inputset" =>
    merge(
      value,
      {
        vars = merge(
          details.pipeline.vars,
          value.vars,
          {
            identifier  = "${lower(replace(key, "-", "_"))}_inputset_${var.suffix}"
            description = value.description
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
        })
      }
    ) }
  ]...)

  trigger_templates = merge([for name, details in var.harness_platform_pipelines : {
    for key, value in details.trigger : "${key}_trigger" =>
    merge(
      value,
      {
        vars = merge(
          details.pipeline.vars,
          details.inputset[value.inputset_ref].vars,
          value.vars,
          {
            identifier  = "${lower(replace(key, "-", "_"))}_trigger_${var.suffix}"
            description = value.description
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
            enabled     = value.enable
          }
        )
      }
    ) }
  ]...)
}
