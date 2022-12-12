locals {
  inputset_output = merge([for pipeline, details in harness_platform_pipeline.pipeline : {
    for key, input in harness_platform_input_set.inputset : key => { identifier = input.identifier } if input.pipeline_id == details.identifier
    }
  ]...)
  trigger_output = merge([for pipeline, details in harness_platform_pipeline.pipeline : {
    for key, trigger in harness_platform_triggers.trigger : key => { identifier = trigger.identifier } if trigger.target_id == details.identifier
    }
  ]...)

  pipeline_output = { for key, details in harness_platform_pipeline.pipeline : key => merge(
    { pipeline_id = details.identifier },
    length(keys(local.inputset_output)) > 0 ? { inputsets = local.inputset_output } : {},
    length(keys(local.trigger_output)) > 0 ? { triggers = local.trigger_output } : {}
    )
  }
}

output "pipelines" {
  value = local.pipeline_output
}
