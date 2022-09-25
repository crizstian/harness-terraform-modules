resource "null_resource" "modify_anka_docker_delegate" {
  for_each   = local.anka_remote_docker_delegates
  depends_on = [null_resource.download_delegate_manifest]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = path.root
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
            yq -i '.services.harness-ng-delegate.environment[17] = "RUNNER_URL=http://host.docker.internal:3000/"' ${each.value.manifest}
            yq -i '.services.harness-ng-delegate.extra_hosts[0] = "host.docker.internal:host-gateway"' ${each.value.manifest}
        EOT
  }
}
