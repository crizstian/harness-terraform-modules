output "workspaces" {
  value = local.workspaces
  # value = { for key, details in harness_platform_workspace.workspace : key =>
  #   {
  #     identifier = details.identifier
  #     org_id     = details.org_id
  #     project_id = details.project_id
  #   }
  # }
}
