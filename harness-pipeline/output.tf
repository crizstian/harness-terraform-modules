locals {
  pipelines_rendered = { for key, details in harness_platform_pipeline.pipeline : key =>
    {
      name    = "${key}/pipeline.yml"
      content = base64encode(data.local_file.pipeline_template[key].content)
    }
  }
  inputset_rendered = merge([for pipeline, details in harness_platform_pipeline.pipeline : {
    for key, input in harness_platform_input_set.inputset : key => {
      name    = "${pipeline}/${key}.yml"
      content = base64encode(data.local_file.inputset_template[key].content)
    } }
  ]...)
  trigger_rendered = merge([for pipeline, details in harness_platform_pipeline.pipeline : {
    for key, trigger in harness_platform_triggers.trigger : key => {
      name    = "${pipeline}/${key}.yml"
      content = base64encode(data.local_file.trigger_template[key].content)
    } }
  ]...)


  files_rendered = merge(
    local.pipelines_rendered,
    local.inputset_rendered,
    local.trigger_rendered
  )
}

locals {
  inputset_output = { for pipeline, details in harness_platform_pipeline.pipeline : pipeline =>
    {
      for key, value in harness_platform_input_set.inputset : key => merge(
        {
          identifier = value.identifier

        },
        can(module.github.0.files[key]) ? { git_file = module.github.0.files[key] } : {}
      ) if value.pipeline_id == details.identifier
    }
  }
  trigger_output = { for pipeline, details in harness_platform_pipeline.pipeline : pipeline => {
    for key, value in harness_platform_triggers.trigger : key => merge(
      {
        identifier = value.identifier

      },
      can(module.github.0.files[key]) ? { git_file = module.github.0.files[key] } : {}
    ) if value.target_id == details.identifier
    }
  }
  pipeline_output = { for key, details in harness_platform_pipeline.pipeline : key => merge(
    {
      pipeline_id = details.identifier
    },
    can(module.github.0.files[key]) ? { git_file = module.github.0.files[key] } : {},
    length(keys(local.inputset_output[key])) > 0 ? { inputsets = local.inputset_output[key] } : {},
    length(keys(local.trigger_output[key])) > 0 ? { triggers = local.trigger_output[key] } : {}
    )
  }
}

output "pipelines" {
  value = local.pipeline_output
}
