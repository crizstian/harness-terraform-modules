output "pipelines" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => {
    identifier = details.identifier
    org_id     = details.org_id
    project_id = details.project_id
  } }
}
output "verbose" {
  value = { for key, details in local.pipelines : key => details }
}
