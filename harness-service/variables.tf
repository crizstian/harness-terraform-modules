variable "harness_platform_services" {
  default = {}
}
variable "harness_platform_variables" {
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
variable "services_path" {
  default = ""
}
variable "harness_platform_service_configs" {
  default = {}
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
