variable "harness_platform_organizations" {
  description = "Harness Organizations to be created in the given Harness account"
  default     = {}
}

variable "harness_platform_projects" {
  description = "Harness Projects to be created in the given Harness account"
  default     = {}
}

variable "suffix" {}
variable "tags" {
  default = []
}
variable "org_id" {
  default = "default"
}

locals {
  orgs = { for name, details in var.harness_platform_organizations : name => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      name       = try(details.short_name, "terraform")
      tags       = concat(try(details.tags, []), var.tags)
    })
    if details.enable && name != "default"
  }

  projs = { for name, details in var.harness_platform_projects : name => merge(
    details,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      name       = try(details.short_name, "terraform")
      org_id     = try(details.org_id, var.org_id)
      tags       = concat(try(details.tags, []), var.tags)
    })
    if details.enable
  }

}
