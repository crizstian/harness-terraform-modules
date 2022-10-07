# resource "random_string" "suffix" {
#   count   = var.suffix != "" ? 0 : 1
#   length  = 4
#   special = false
#   lower   = true
# }

resource "harness_platform_pipeline" "pipeline" {
  for_each    = local.pipelines
  description = each.value.description
  identifier  = "${each.value.identifier}_${var.suffix}"
  name        = each.key
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  yaml        = each.value.yaml
}

resource "harness_platform_input_set" "inputset" {
  for_each    = local.inputsets
  description = each.value.description
  identifier  = "${each.value.identifier}_${var.suffix}"
  name        = each.key
  org_id      = each.value.org_id
  project_id  = each.value.project_id
  pipeline_id = each.value.pipeline_id
  yaml        = each.value.yaml
}

output "pipelines" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => { pipeline_id = details.identifier } }
}
output "inputsets" {
  value = { for key, details in harness_platform_input_set.inputset : key => { inputset_id = details.identifier } }
}
