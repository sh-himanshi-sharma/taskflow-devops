terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

variable "replica_count" {
  description = "Number of TaskFlow application containers"
  type        = number
  default     = 2
}

resource "docker_image" "taskflow" {
  name         = "taskflow-terraform:1.0"
  keep_locally = true
}

resource "docker_container" "taskflow" {
  count = var.replica_count

  name  = "taskflow-${count.index + 1}"
  image = docker_image.taskflow.image_id

  ports {
    internal = 5000
    external = 5001 + count.index
  }
}

output "taskflow_container_names" {
  value = docker_container.taskflow[*].name
}

output "taskflow_access_ports" {
  value = [for container in docker_container.taskflow : container.ports[0].external]
}
