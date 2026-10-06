terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "microapp_net" {
  name = "microapp-net"
}

resource "docker_image" "ubuntu" {
  name = "ubuntu:22.04"
}

resource "docker_container" "vm_haproxy" {
  name     = "vm-haproxy"
  image    = docker_image.ubuntu.image_id
  hostname = "vm-haproxy"

  command = ["bash", "-c", <<-EOT
    while true; do
      if [ -x /usr/sbin/haproxy ] && [ -f /etc/haproxy/haproxy.cfg ]; then
        if ! pgrep -x haproxy > /dev/null; then
          haproxy -f /etc/haproxy/haproxy.cfg -D
        fi
      fi
      sleep 5
    done
  EOT
  ]

  networks_advanced {
    name = docker_network.microapp_net.name
  }

  ports {
    internal = 80
    external = 8080
  }

  ports {
    internal = 8404
    external = 8404
  }

  restart = "unless-stopped"
}

resource "docker_container" "vm_microservices" {
  name       = "vm-microservices"
  image      = docker_image.ubuntu.image_id
  hostname   = "vm-microservices"
  privileged = true

  command = ["bash", "-c", <<-EOT
    mkdir -p /etc/docker
    echo '{"storage-driver":"vfs"}' > /etc/docker/daemon.json
    while true; do
      if [ -x /usr/bin/dockerd ]; then
        if ! pgrep -x dockerd > /dev/null; then
          dockerd > /var/log/dockerd.log 2>&1 &
          sleep 5
        fi
      fi
      sleep 5
    done
  EOT
  ]

  networks_advanced {
    name = docker_network.microapp_net.name
  }

  restart = "unless-stopped"
}

output "vm_haproxy_id" {
  value = docker_container.vm_haproxy.id
}

output "vm_microservices_id" {
  value = docker_container.vm_microservices.id
}
