# organizations = {
#     org-A = {
#         enable      = true
#         name        = ""
#         description = ""
#         projects = {
#         project-A = {
#           enable      = true
#           description = ""
#         }
#     }
# }

variable "harness_platform_organizations" {
  description = "Harness Organizations to be created in the given Harness account"
  default     = {}
}

variable "harness_platform_projects" {
  description = "Harness Projects to be created in the given Harness account"
  default     = {}
}

locals {
  orgs = { for name, organization in var.harness_platform_organizations : name =>
    {
      identifier  = lower(replace(name, "/[\\s-.]/", "_"))
      description = organization.description
    }
    if organization.enable && name != "default"
  }

  projs = { for name, project in var.harness_platform_projects : name =>
    {
      identifier  = lower(replace(name, "/[\\s-.]/", "_"))
      description = project.description
      org_id      = try(project.org_id, "default")
    }
    if organization.enable
  }
}
