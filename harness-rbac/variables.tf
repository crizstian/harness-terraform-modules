variable "suffix" {
  type = string
}
variable "global_tags" {
  default = []
  type    = list(string)
}
variable "org_id" {
  default = "default"
  type    = string
}
variable "project_id" {
  default = ""
  type    = string
}
variable "harness_platform_roles" {
  default = {}
}
variable "harness_platform_users" {
  default = {}
}
variable "harness_platform_user_groups" {
  default = {}
}
