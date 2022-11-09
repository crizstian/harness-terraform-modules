terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "harness/harness"
      version = ">= 0.7.1"
    }
  }
}
