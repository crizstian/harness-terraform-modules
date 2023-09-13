variable "pipelines" {
  default = {}
}
variable "harness_platform_inputsets" {
  default = {}
}
variable "harness_platform_triggers" {
  default = {}
}
variable "harness_platform_services" {
  default = {}
}
variable "harness_platform_service_configs" {
  default = {}
}
variable "harness_platform_environments" {
  default = {}
}
variable "harness_platform_infrastructures" {
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

variable "usergroups" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
