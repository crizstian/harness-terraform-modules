variable "suffix" {}
variable "tags" {
  default = []
}
variable "org_id" {
  default = ""
}
variable "project_id" {
  default = ""
}
variable "organizations" {
  default = {}
}
variable "projects" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}

variable "harness_platform_policies" {
  description = "Harness policies to be created in the given Harness account"
  default     = {}
}
variable "harness_platform_policy_sets" {
  description = "Harness policies to be created in the given Harness account"
  default     = {}
}
