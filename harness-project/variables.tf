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

variable "harness_platform_projects" {
  description = "Harness Organizations/Projects to be created in the given Harness account"
  type        = map(any)
  default     = {}
}

locals {
  orgs = { for name, organization in var.harness_platform_projects : name =>
    {
      identifier  = lower(replace(name, "/[\\s-.]/", "_"))
      description = organization.description
    }
    if organization.enable && name != "default"
  }

  projs = merge([for name, organization in var.harness_platform_projects : { for p_name, project in organization.projects : p_name =>
    {
      identifier  = lower(replace(p_name, "/[\\s-.]/", "_"))
      description = project.description
      org_id      = try(harness_platform_organization.org[name].identifier, "default")
    }
    } if organization.enable
  ]...)
}
