variable "suffix" {}
variable "tags" {
  default = []
}
variable "harness_platform_templates" {
  description = "Harness Templates to be created in the given Harness account"
  default     = {}
}

locals {
  harness_templates = { for name, details in var.harness_platform_templates : name => merge(
    details.pipeline,
    {
      tags = concat(details.pipeline.vars.tags, var.tags)
      vars = merge(
        details.pipeline.vars,
        {
          git_details = try(details.pipeline.vars.git_details, {})
          identifier  = "${lower(replace(name, "-", "_"))}_${var.suffix}"
          description = details.pipeline.description
      })
    })
  }
}
