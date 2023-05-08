resource "harness_platform_template" "step" {
  for_each      = local.steps
  name          = each.key
  description   = each.value.vars.description
  identifier    = each.value.vars.identifier
  org_id        = each.value.vars.org_id
  project_id    = each.value.vars.project_id
  tags          = each.value.vars.tags
  version       = each.value.vars.version
  comments      = each.value.vars.comments
  is_stable     = each.value.vars.is_stable
  template_yaml = templatefile(each.value.vars.yaml, each.value.vars)

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
resource "harness_platform_template" "stage" {
  depends_on    = [harness_platform_template.step]
  for_each      = local.stages
  name          = each.key
  description   = each.value.vars.description
  identifier    = each.value.vars.identifier
  org_id        = each.value.vars.org_id
  project_id    = each.value.vars.project_id
  tags          = each.value.vars.tags
  version       = each.value.vars.version
  comments      = each.value.vars.comments
  is_stable     = each.value.vars.is_stable
  template_yaml = templatefile(each.value.vars.yaml, each.value.vars)

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
resource "harness_platform_template" "template_deployment" {
  for_each      = local.template_deployment
  name          = each.key
  description   = each.value.vars.description
  identifier    = each.value.vars.identifier
  org_id        = each.value.vars.org_id
  project_id    = each.value.vars.project_id
  tags          = each.value.vars.tags
  version       = each.value.vars.version
  comments      = each.value.vars.comments
  is_stable     = each.value.vars.is_stable
  template_yaml = templatefile(each.value.vars.yaml, each.value.vars)

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
resource "harness_platform_template" "pipeline" {
  depends_on    = [harness_platform_template.stage, harness_platform_template.template_deployment]
  for_each      = local.pipelines
  name          = each.key
  description   = each.value.vars.description
  identifier    = each.value.vars.identifier
  org_id        = each.value.vars.org_id
  project_id    = each.value.vars.project_id
  tags          = each.value.vars.tags
  version       = each.value.vars.version
  comments      = each.value.vars.comments
  is_stable     = each.value.vars.is_stable
  template_yaml = templatefile(each.value.vars.yaml, each.value.vars)

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
resource "harness_platform_template" "template" {
  for_each      = local.definitions
  name          = each.key
  description   = each.value.vars.description
  identifier    = each.value.vars.identifier
  org_id        = each.value.vars.org_id
  project_id    = each.value.vars.project_id
  tags          = each.value.vars.tags
  version       = each.value.vars.version
  comments      = each.value.vars.comments
  is_stable     = each.value.vars.is_stable
  template_yaml = templatefile(each.value.vars.yaml, each.value.vars)

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
