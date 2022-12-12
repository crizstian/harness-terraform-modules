output "pipelines" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => merge(
    { pipeline_id = details.identifier },
    length(keys(harness_platform_input_set.inputset)) > 0 ? { inputsets = { for key, input in harness_platform_input_set.inputset : key => { identifier = input.identifier } if input.pipeline_id == details.identifier } } : {},
    length(keys(harness_platform_triggers.trigger)) > 0 ? { triggers = { for key, trigger in harness_platform_triggers.trigger : key => { identifier = trigger.identifier } if trigger.pipeline_id == details.identifier } } : {}
    )
  }
}
