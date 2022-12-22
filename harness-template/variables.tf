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
    details,
    {
      vars = merge(
        details.vars,
        {
          tags        = concat(details.tags, var.tags)
          git_details = try(details.vars.git_details, {})
          identifier  = "${lower(replace(name, "-", "_"))}_template_${var.suffix}"
          description = details.description
      })
    })
  }
}
