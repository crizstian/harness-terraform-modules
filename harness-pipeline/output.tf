locals {
  pipelines_rendered = { for pipeline, values in harness_platform_pipeline.pipeline : pipeline =>
    {
      name    = "${pipeline}/pipeline.yml"
      content = base64encode(data.local_file.pipeline_template[pipeline].content)
    }
  }
  inputset_rendered = merge([for pipeline, details in harness_platform_pipeline.pipeline : { for inputset, values in details.inputsets : inputset =>
    {
      name    = "${pipeline}/${inputset}.yml"
      content = base64encode(data.local_file.inputset_template[inputset].content)
    }
  }]...)
  trigger_rendered = merge([for pipeline, details in harness_platform_pipeline.pipeline : { for trigger, values in details.triggers : trigger =>
    {
      name    = "${pipeline}/${trigger}.yml"
      content = base64encode(data.local_file.trigger_template[trigger].content)
    }
  }]...)

  files_rendered = merge(
    local.pipelines_rendered,
    local.inputset_rendered,
    local.trigger_rendered
  )
}

locals {
  inputset_output = { for pipeline, details in harness_platform_pipeline.pipeline : pipeline => {
    for key, input in harness_platform_input_set.inputset : key => { identifier = input.identifier } if input.pipeline_id == details.identifier }
  }
  trigger_output = { for pipeline, details in harness_platform_pipeline.pipeline : pipeline => {
    for key, trigger in harness_platform_triggers.trigger : key => { identifier = trigger.identifier } if trigger.target_id == details.identifier }
  }
  pipeline_output = { for key, details in harness_platform_pipeline.pipeline : key => merge(
    {
      pipeline_id = details.identifier
    },
    length(keys(local.inputset_output[key])) > 0 ? { inputsets = local.inputset_output[key] } : {},
    length(keys(local.trigger_output[key])) > 0 ? { triggers = local.trigger_output[key] } : {}
    )
  }
}

output "pipelines" {
  value = local.pipeline_output
}
