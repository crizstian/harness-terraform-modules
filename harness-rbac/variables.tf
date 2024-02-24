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
variable "policies" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
variable "harness_platform_roles" {
  default = {}
}
variable "harness_platform_users" {
  default = {}
}
variable "harness_platform_usergroups" {
  default = {}
}
variable "harness_platform_service_accounts" {
  default = {}
}
