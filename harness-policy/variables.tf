variable "suffix" {}
variable "tags" {
  default = []
}
variable "harness_platform_policies" {
  description = "Harness policies to be created in the given Harness account"
  default     = {}
}
variable "org_id" {
  default = ""
}
variable "project_id" {
  default = ""
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
locals {
  harness_policies = { for name, details in var.harness_platform_policies : name => merge(
    details,
    {
      org_id      = try(details.org_id, var.org_id)
      project_id  = try(details.project_id, var.project_id)
      tags        = concat(try(details.tags, []), var.tags)
      identifier  = "${lower(replace(name, "-", "_"))}_template_${var.suffix}"
      description = details.description
    }
  ) }
}
