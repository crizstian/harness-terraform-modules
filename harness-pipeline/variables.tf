variable "harness_platform_pipelines" {
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
variable "services" {
  default = {}
}
variable "environments" {
  default = {}
}
variable "usergroups" {
  default = {}
}
variable "infrastructures" {
  default = {}
}
