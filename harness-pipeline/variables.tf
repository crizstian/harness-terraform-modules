variable "harness_platform_pipelines" {
  description = "Harness Pipelines to be created in the given Harness account"
  default     = {}
}

variable "harness_platform_inputsets" {
  description = "Harness Inputsets to be created in the given Harness account"
  default     = {}
}

locals {
  pipelines = { for name, pipeline in var.harness_platform_pipelines : name =>
    {

      identifier  = lower(replace(name, "/[\\s-.]/", "_"))
      name        = name
      org_id      = pipeline.org_id
      project_id  = pipeline.project_id
      yaml        = pipeline.yaml
      description = pipeline.description

    }
    if pipeline.enable
  }
  inputsets = { for name, inputset in var.harness_platform_inputsets : name =>
    {
      identifier  = lower(replace(name, "/[\\s-.]/", "_"))
      name        = name
      description = inputset.description
      org_id      = inputset.org_id
      project_id  = inputset.project_id
      pipeline_id = inputset.pipeline_id
      yaml        = inputset.yaml
    }
    if inputset.enable
  }
}
