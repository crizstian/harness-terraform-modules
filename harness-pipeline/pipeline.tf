# Renders Pipeline
module "render_pipeline_template_files" {
  source            = "../terraform-templates"
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
  for_each    = local.pipeline_templates
  description = each.value.description
  identifier  = each.value.vars.identifier
  name        = each.key
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.tags
  yaml        = data.local_file.pipeline_template[each.key].content
}
