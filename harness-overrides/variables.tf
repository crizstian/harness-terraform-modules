variable "harness_platform_overrides" {
  default = {}
}
variable "environments" {
  default = {}
}
variable "suffix" {}
variable "org_id" {
  default = ""
}
variable "env_id" {
  default = ""
}
variable "organizations" {
  default = {}
}
variable "projects" {
  default = {}
}
variable "templates" {
  default = {}
}
variable "connectors" {
  default = {}
}
variable "project_id" {
  default = ""
}
variable "tags" {
  default = ""
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
