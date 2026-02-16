terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
    }
  }
}

provider "lxd" {}

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

  profiles = ["default"]
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

  profiles = ["default"]
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

  profiles = ["default"]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl", {
    manager_ip = "${lxd_instance.swarm_manager.name}.lxd"
    worker1_ip = "${lxd_instance.swarm_worker1.name}.lxd"
    worker2_ip = "${lxd_instance.swarm_worker2.name}.lxd"
  })
  filename = "./ansible/inventory.ini"
}
