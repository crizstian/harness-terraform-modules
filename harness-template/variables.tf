variable "suffix" {}
variable "tags" {
  default = []
}
variable "harness_platform_templates" {
  description = "Harness Templates to be created in the given Harness account"
  default     = {}
}
variable "org_id" {
  default = ""
}
variable "project_id" {
  default = ""
}


locals {
  harness_templates = { for name, details in var.harness_platform_templates : name => merge(
    details,
    {
      vars = merge(
        details.vars,
        {
          org_id      = try(details.org_id, var.org_id)
          project_id  = try(details.project_id, var.project_id)
          tags        = concat(details.tags, var.tags)
          git_details = try(details.vars.git_details, {})
          identifier  = "${lower(replace(name, "-", "_"))}_template_${var.suffix}"
          description = details.description
      })
    })
  }
}
