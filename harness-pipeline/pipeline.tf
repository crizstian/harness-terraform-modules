# Renders Pipeline
module "render_pipeline_template_files" {
  # source            = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
  source            = "../harness-templates"
  harness_templates = local.pipeline_templates
}

# Loads Pipeline files in order to provision it with terraform
data "local_file" "pipeline_template" {
  depends_on = [
    module.render_pipeline_template_files
  ]
  for_each = local.pipeline_templates
  filename = module.render_pipeline_template_files.files[each.key]
}

resource "harness_platform_pipeline" "pipeline" {
  for_each    = local.pipelines
  description = each.value.description
  identifier  = each.value.identifier
  name        = each.key
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  yaml        = each.value.yaml
}

output "pipelines" {
  value = { for key, details in harness_platform_pipeline.pipeline : key => { pipeline_id = details.identifier } }
}
