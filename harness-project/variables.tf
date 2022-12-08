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

locals {
  orgs = { for name, organization in var.harness_platform_organizations : name => merge(
    organization,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      name       = try(organization.short_name, "terraform")
      tags       = try(organization.tags, var.tags)
    })
    if organization.enable && name != "default"
  }

  projs = { for name, project in var.harness_platform_projects : name => merge(
    project,
    {
      identifier = "${lower(replace(name, "/[\\s-.]/", "_"))}_${var.suffix}"
      name       = try(project.short_name, "terraform")
      org_id     = try(project.org_id, "default")
      tags       = try(project.tags, var.tags)
    })
    if project.enable
  }

}
