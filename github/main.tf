resource "github_repository" "repository" {
  name        = "harness_files_${var.organization_prefix}"
  description = "Repository created by Terraform provider"
  visibility  = "public"
  auto_init   = true
}

resource "github_repository_file" "pipelines" {
  for_each            = var.files_rendered
  repository          = github_repository.repository.name
  branch              = var.github_details.branch
  file                = each.key
  content             = base64decode(each.value)
  commit_message      = var.github_details.commit_message
  commit_author       = var.github_details.commit_author
  commit_email        = var.github_details.commit_email
  overwrite_on_create = true
}

output "files" {
  value = { for key, value in var.files_rendered : key => "harness_files_${var.organization_prefix}/${key}" }
}
