# resource "null_resource" "modify_anka_docker_delegate" {
#   for_each   = local.anka_remote_docker_delegates
#   depends_on = [null_resource.download_delegate_manifest]

#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     working_dir = path.root
#     interpreter = ["/bin/bash", "-c"]
#     command     = <<-EOT
#             yq -i '.services.harness-ng-delegate.environment[17] = "RUNNER_URL=http://host.docker.internal:3000/"' ${each.value.manifest}
#             yq -i '.services.harness-ng-delegate.extra_hosts[0] = "host.docker.internal:host-gateway"' ${each.value.manifest}
#         EOT
#   }
# }

resource "null_resource" "install_docker_linux_delegate" {
  for_each   = local.install_docker_delegates
  depends_on = [null_resource.harness_file]

  triggers = {
    delegates = "${each.key}"
  }

  connection {
    type        = "ssh"
    user        = each.value.connection.user
    host        = each.value.connection.host
    private_key = each.value.connection.private_key
  }

  provisioner "file" {
    source      = each.value.docker_manifest
    destination = "/tmp/${each.value.docker_manifest}"
  }

  provisioner "file" {
    source      = "${path.module}/drone-runner-linux.service"
    destination = "/etc/systemd/system"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/local/bin/",
      "curl -o drone-docker-runner-linux https://github.com/harness/drone-docker-runner/releases/download/v0.1.0/drone-docker-runner-linux-amd64",
      "chmod +x drone-docker-runner-linux",
      "mv drone-docker-runner-linux /usr/bin",
      "docker-compose -f /tmp/${each.value.docker_manifest} up -d",
      "systemctl daemon-reload",
      "service drone-docker-runner-linux restart"
    ]
  }
}
