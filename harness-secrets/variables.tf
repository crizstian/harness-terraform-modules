# Harness Platform variables
variable "harness_platform_secrets_text" {
  type      = map(string)
  sensitive = false
}
variable "harness_platform_secrets_file" {
  type      = map(string)
  sensitive = false
}
