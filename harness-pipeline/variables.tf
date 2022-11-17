variable "suffix" {}

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
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
    })
  }

  pipelines = { for name, details in local.pipeline_templates : name => merge(
    details,
    {
      yaml = data.local_file.pipeline_template[name].content
    })
  }

  # pipeline_non_templatized = { for name, details in var.harness_platform_pipelines : name => details
  #   if !can(details.custom_template.pipeline)
  # }

  # all_pipelines = merge(local.pipeline_rendered, local.pipeline_non_templatized)

  # pipelines = { for name, details in local.all_pipelines : name => details }

  inputset_templates = merge([for name, details in var.harness_platform_pipelines : {
    for key, value in details.custom_template.inputset : "${name}_inputset_${key}" => merge(
      value,
      {
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_inputset_${lower(replace(key, "/[\\s-.]/", "_"))}_${var.suffix}"
        vars = merge(value.vars,
          {
            pipeline_id = harness_platform_pipeline.pipeline[name].identifier
          }
        )
    }) if value.enable
    } if can(details.custom_template.inputset)
  ]...)

  inputset_rendered = { for name, details in local.inputset_templates : name => merge(
    details,
    {
      yaml = data.local_file.inputset_template[name].content
    })
  }

  inputsets = { for name, details in local.inputset_rendered : name => details }
}
