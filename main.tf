terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

provider "lxd" {

}

resource "lxd_instance" "swarm_manager" {
  name  = "swarm-manager"
  image = "ubuntu:22.04"

  config = {
    "security.nesting"    = "true"
    "security.privileged" = "true"
  }

  limits = {
    cpu    = "2"
    memory = "2GB"
  }
}

resource "lxd_instance" "swarm_worker1" {
  name  = "swarm-worker1"
  image = "ubuntu:22.04"

  config = {
    "security.nesting"    = "true"
    "security.privileged" = "true"
  }

  limits = {
    cpu    = "2"
    memory = "2GB"
  }
}

resource "lxd_instance" "swarm_worker2" {
  name  = "swarm-worker2"
  image = "ubuntu:22.04"

  config = {
    "security.nesting"    = "true"
    "security.privileged" = "true"
  }

  limits = {
    cpu    = "2"
    memory = "2GB"
  }
}

output "swarm_ips" {
  value = {
    manager = lxd_instance.swarm_manager.ipv4_address
    worker1 = lxd_instance.swarm_worker1.ipv4_address
    worker2 = lxd_instance.swarm_worker2.ipv4_address
  }
}
