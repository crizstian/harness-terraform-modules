# Renders InputSet files in order to provision it with terraform
module "render_inputset_template_files" {
  source            = "../harness-templates"
  harness_templates = local.inputset_templates
}

# Loads InputSet files in order to provision it with terraform
data "local_file" "inputset_template" {
  depends_on = [
    module.render_inputset_template_files
  ]
  for_each = local.inputset_templates
  filename = module.render_inputset_template_files.files[each.key]
}

resource "harness_platform_input_set" "inputset" {
  for_each    = local.inputset_templates
  description = each.value.description
  identifier  = each.value.vars.identifier
  name        = each.key
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  pipeline_id = each.value.vars.pipeline_id
  yaml        = data.local_file.inputset_template[each.key].content
}
