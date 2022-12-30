locals {
  policy_output = { for key, details in harness_platform_policy.policy : key =>
    {
      identifier = details.project_id != "" ? details.identifier : details.org_id != "" ? "org.${details.identifier}" : "account.${details.identifier}"
    }
  }
}

output "policys" {
  value = local.policy_output
}
