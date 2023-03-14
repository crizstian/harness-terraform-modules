variable "suffix" {
  type = string
}
variable "global_tags" {
  default = []
  type    = list(string)
}
variable "org_id" {
  default = "default"
  type    = string
}

variable "harness_platform_organizations" {
  description = "Harness Organizations to be created in the given Harness account"
  default     = {}
  type = map(object({
    description = string
    tags        = list(string)
    enable      = bool
  }))
}

variable "harness_platform_projects" {
  description = "Harness Projects to be created in the given Harness account"
  default     = {}
  type = map(object({
    description = string
    tags        = list(string)
    enable      = bool
  }))
}

locals {
  orgs = { for name, details in var.harness_platform_organizations : name => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      tags       = concat(try(details.tags, []), var.global_tags)
    })
    if details.enable && name != "default"
  }

  org_id_by_tag = merge([for org, details in harness_platform_organization.org : { for index, tag in details.tags : tag => details.identifier if startswith(tag, "owner: ") }]...)
  prj_by_tag    = merge([for prj, details in var.harness_platform_projects : { for index, tag in details.tags : prj => index if startswith(tag, "owner: ") }]...)

  /* org_id_by_tag = { for org, details in harness_platform_organization.org : var.harness_platform_organizations[org].tags[0] => details.identifier } */

  prjs = { for name, details in var.harness_platform_projects : name =>
    merge(
      details,
      {
        identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
        tags       = concat(try(details.tags, []), var.global_tags)
        org_id     = try(local.org_id_by_tag[details.tags[local.prj_by_tag[name]]], var.org_id)
    })
    if details.enable
  }
}

output "org_id_by_tag" {
  value = local.org_id_by_tag
}
output "prj_by_tag" {
  value = local.prj_by_tag
}