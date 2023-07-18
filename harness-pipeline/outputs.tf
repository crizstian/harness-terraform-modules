output "pipeline" {
  value = merge(
    { for key, details in harness_platform_pipeline.pipeline : key => {
      identifier     = details.identifier
      org_id         = details.org_id
      project_id     = details.project_id
      default_values = local.pipelines[key].default_values
    } },
    { for key, details in harness_platform_pipeline.chained_pipelines : key => {
      identifier     = details.identifier
      org_id         = details.org_id
      project_id     = details.project_id
      default_values = local.chained_pipelines[key].default_values
    } }
  )
}
output "verbose" {
  value = { for key, details in local.pipelines : key => details }
}
