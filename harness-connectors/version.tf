terraform {
  required_version = ">= 0.13.1"

  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.7.1"
    }
  }
}
