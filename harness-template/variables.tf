variable "harness_platform_templates" {
  default = {}
}
variable "suffix" {}
variable "org_id" {
  default = ""
}
variable "project_id" {
  default = ""
}
variable "tags" {
  default = ""
}
variable "organizations" {
  default = {}
}
variable "projects" {
  default = {}
}
variable "connectors" {
  default = {}
}
variable "usergroups" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
