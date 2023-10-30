variable "harness_platform_github_connectors" {
  default = {}
}
variable "harness_platform_aws_connectors" {
  default = {}
}
variable "harness_platform_gitlab_connectors" {
  default = {}
}
variable "harness_platform_docker_connectors" {
  default = {}
}
variable "harness_platform_artifactory_connectors" {
  default = {}
}
variable "harness_platform_gcp_connectors" {
  default = {}
}
variable "harness_platform_nexus_connectors" {
  default = {}
}
variable "harness_platform_service_now_connectors" {
  default = {}
}
variable "harness_platform_dynatrace_connectors" {
  default = {}
}
variable "harness_platform_kubernetes_connectors" {
  default = {}
}
variable "harness_platform_newrelic_connectors" {
  default = {}
}
variable "harness_platform_helm_connectors" {
  default = {}
}
variable "harness_platform_kubernetes_ccm_connectors" {
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
  default = []
}
variable "delegate_selectors" {
  default = []
}
variable "common_values" {
  default = {
    org_id     = ""
    project_id = ""
  }
}
