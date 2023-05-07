variable "suffix" {
  type = string
}
variable "tags" {
  default = []
  type    = list(string)
}
variable "harness_platform_organizations" {
  description = "Harness Organizations to be created in the given Harness account"
  default     = {}
}

variable "harness_platform_projects" {
  description = "Harness Projects to be created in the given Harness account"
  default     = {}
}
