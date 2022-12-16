# Rendered Files to be stored in git
module "github" {
  source              = "../github"
  count               = var.store_pipelines_in_git ? 1 : 0
  organization_prefix = var.organization_prefix
  github_details      = var.github_details
  files_rendered      = local.files_rendered
}
