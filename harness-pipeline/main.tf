resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}

resource "harness_platform_pipeline" "pipeline" {
  for_each   = local.pipelines
  identifier = "${each.value.identifier}_${random_string.suffix.id}"
  name       = each.key
  org_id     = each.value.org_id
  project_id = each.value.project_id
  yaml       = file(each.value.yaml)
}

resource "harness_platform_pipeline" "inputset" {
  for_each    = local.inputsets
  identifier  = "${each.value.identifier}_${random_string.suffix.id}"
  name        = each.key
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  pipeline_id = each.value.pipeline_id
  yaml        = file(each.value.yaml)
}

output "pipeline" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => { pipeline_id = details.identifier } }
}
output "inputset" {
  value = { for key, details in harness_platform_inputset.inputset : key => { inputset_id = details.identifier } }
}
