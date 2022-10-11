variable "harness_templates" {
  default = {}
}

variable "harness_template_endpoint" {
  default = "https://app.harness.io/gateway/template/api/templates"
}
variable "harness_platform_api_key" {
  default = ""
}
variable "harness_template_endpoint_account_args" {
  default = ""
}

locals {
  crafted_templates = { for key, value in var.harness_templates : key => value if value.craft_request }
}
