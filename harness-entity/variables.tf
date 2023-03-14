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

  prjs = { for name, details in var.harness_platform_projects : name => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      tags       = concat(try(details.tags, []), var.global_tags)
      org_id     = try(details.org_id, var.org_id)
    })
    if details.enable
  }
}
