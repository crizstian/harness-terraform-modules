resource "harness_platform_workspace" "workspace" {
  for_each                = local.workspaces
  name                    = each.key
  identifier              = each.value.identifier
  org_id                  = each.value.org_id
  project_id              = each.value.project_id
  provisioner_type        = "terraform"
  provisioner_version     = "1.5.6"
  repository              = each.value.repository
  repository_branch       = each.value.repository_branch
  repository_path         = each.value.repository_path
  cost_estimation_enabled = each.value.cost_estimation_enabled
  provider_connector      = each.value.provider_connector
  repository_connector    = each.value.repository_connector

  dynamic "terraform_variable" {
    for_each = each.value.terraform_variable
    content {
      key        = terraform_variable.value.key
      value      = terraform_variable.value.value
      value_type = terraform_variable.value.value_type
    }
  }

  dynamic "environment_variable" {
    for_each = each.value.environment_variable
    content {
      key        = environment_variable.value.key
      value      = environment_variable.value.value
      value_type = environment_variable.value.value_type
    }
  }

  dynamic "terraform_variable_file" {
    for_each = each.value.terraform_variable_file
    content {
      repository           = terraform_variable_file.value.repository
      repository_branch    = terraform_variable_file.value.repository_branch
      repository_path      = terraform_variable_file.value.repository_path
      repository_connector = terraform_variable_file.value.repository_connector
    }
  }
}
