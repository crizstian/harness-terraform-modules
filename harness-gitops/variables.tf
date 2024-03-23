variable "harness_platform_gitops_agent" {
  default = {}
}
variable "harness_platform_gitops_cluster" {
  default = {}
}
variable "harness_platform_gitops_applications" {
  default = {}
}
variable "harness_platform_gitops_repository" {
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
variable "connectors" {
  default = {}
}
variable "templates" {
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
