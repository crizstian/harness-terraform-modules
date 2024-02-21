locals {
  policy_output = { for key, details in harness_platform_policy.policy : key =>
    {
      identifier = details.project_id != "" ? details.identifier : details.org_id != "" ? "org.${details.identifier}" : "account.${details.identifier}"
    }
  }
  policyset_output = { for key, details in harness_platform_policyset.policyset : key =>
    {
      identifier = details.project_id != "" ? details.identifier : details.org_id != "" ? "org.${details.identifier}" : "account.${details.identifier}"
    }
  }
}

output "policies" {
  value = local.policy_output
}
output "policie_sets" {
  value = local.policyset_output
}
