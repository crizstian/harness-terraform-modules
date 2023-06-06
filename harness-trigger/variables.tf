variable "pipelines" {
  default = {}
}
variable "inputsets" {
  default = {}
}
variable "harness_platform_triggers" {
  default = {}
}
variable "harness_platform_services" {
  default = {}
}
variable "suffix" {}
variable "org_id" {
  default = ""
}
variable "project_id" {
  default = ""
}
variable "pipeline_id" {
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
variable "templates" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
