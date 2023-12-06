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

data "harness_platform_secret_text" "private_key" {
  for_each   = local.install_docker_delegates
  identifier = each.value.connection.private_key
}

resource "null_resource" "install_docker_unix_delegate" {
  for_each   = local.install_docker_delegates
  depends_on = [null_resource.harness_file]

  triggers = {
    delegates = "${each.key}"
  }

  connection {
    type        = "ssh"
    user        = each.value.connection.user
    host        = each.value.connection.host
    private_key = data.harness_platform_secret_text.private_key[each.key].value
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
      "curl -o drone-docker-runner-linux ${var.harness_docker_drone_runner_endpoint}",
      "chmod +x drone-docker-runner-linux",
      "mv drone-docker-runner-linux /usr/bin",
      "docker-compose -f /tmp/${each.value.docker_manifest} up -d",
      "systemctl daemon-reload",
      "service drone-docker-runner-linux restart"
    ]
  }
}
