variable "harness_platform_workspaces" {
  default = {}
}
variable "suffix" {}
variable "org_id" {
  default = ""
}
variable "organizations" {
  default = {}
}
variable "projects" {
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
