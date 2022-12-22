# Renders harness template files
module "render_harness_template_files" {
  source            = "../terraform-templates"
  harness_templates = local.harness_templates
}

# Loads harness template files in order to provision it with terraform
data "local_file" "harness_template" {
  depends_on = [
    module.render_harness_template_files
  ]
  for_each = local.harness_templates
  filename = module.render_harness_template_files.files[each.key]
}

resource "harness_platform_template" "template" {
  for_each    = local.harness_templates
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  name        = each.key
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.tags
  yaml        = data.local_file.pipeline_template[each.key].content
  comments    = each.value.vars.comments
  version     = each.value.vars.version
  is_stable   = each.value.vars.is_stable

  dynamic "git_details" {
    for_each = each.value.vars.git_details
    content {
      branch_name    = git_details.value["branch_name"]
      commit_message = git_details.value["commit_message"]
      file_path      = git_details.value["file_path"]
      connector_ref  = git_details.value["connector_ref"]
      store_type     = git_details.value["store_type"]
      repo_name      = git_details.value["repo_name"]
    }
  }
}
