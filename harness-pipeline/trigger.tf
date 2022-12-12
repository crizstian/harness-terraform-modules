# Renders trigger files in order to provision it with terraform
module "render_trigger_template_files" {
  source            = "../harness-templates"
  harness_templates = local.trigger_templates
}

# Loads trigger files in order to provision it with terraform
data "local_file" "trigger_template" {
  depends_on = [
    module.render_trigger_template_files
  ]
  for_each = local.trigger_templates
  filename = module.render_trigger_template_files.files[each.key]
}

resource "harness_platform_triggers" "trigger" {
  for_each    = local.trigger_templates
  description = each.value.description
  identifier  = each.value.vars.identifier
  name        = each.key
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  target_id   = each.value.vars.pipeline_id
  yaml        = data.local_file.trigger_template[each.key].content
}
