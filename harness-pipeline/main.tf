data "harness_platform_template" "template" {
  for_each   = local.templates
  org_id     = each.value.org_id
  project_id = each.value.project_id
  identifier = each.value.template_id
  version    = each.value.template_version
}

resource "harness_platform_pipeline" "pipeline" {
  for_each    = local.pipelines
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.vars.tags
  yaml        = templatefile(each.value.vars.yaml, each.value.vars)


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

resource "harness_platform_pipeline" "chained_pipelines" {
  for_each    = local.chained_pipelines
  name        = each.key
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  tags        = each.value.vars.tags
  yaml        = templatefile(each.value.vars.yaml, each.value.vars)


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

resource "harness_platform_input_set" "inputset" {
  for_each    = local.inputsets
  name        = each.value.vars.name
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  pipeline_id = each.value.vars.pipeline_id
  tags        = each.value.vars.tags
  yaml        = templatefile(each.value.vars.yaml, each.value.vars)

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

resource "harness_platform_triggers" "trigger" {
  for_each    = local.triggers
  name        = each.value.vars.name
  description = each.value.vars.description
  identifier  = each.value.vars.identifier
  org_id      = each.value.vars.org_id
  project_id  = each.value.vars.project_id
  target_id   = each.value.vars.pipeline_id
  tags        = each.value.vars.tags
  yaml        = templatefile(each.value.vars.yaml, each.value.vars)
}
