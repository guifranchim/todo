
variable "gcp_project_id" {
  description = "O ID do seu projeto GCP."
  type        = string
  default     = "exalted-legacy-459419-m8"
}

variable "gcp_region" {
  description = "A região onde os recursos serão criados."
  type        = string
  default     = "southamerica-east1"
}

variable "state_environments" {
  description = "Ambientes para criar buckets de state."
  type        = list(string)
  default     = ["stage", "production"]
}

variable "cluster_name" {
  description = "O nome para o seu cluster GKE."
  type        = string
  default     = "todo-ua"
}

variable "network_name" {
  description = "O nome da rede VPC a ser usada pelo cluster."
  type        = string
  default     = "default"
}

variable "node_pool_name" {
  description = "O nome do pool de nós para o cluster."
  type        = string
  default     = "default-pool"
}

variable "node_count" {
  description = "O número inicial de nós no node pool."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "O tipo de máquina para os nós do GKE."
  type        = string
  default     = "e2-medium"
}

terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_storage_bucket" "tf_state" {
  name                        = "tf-state-261909652338-${each.value}"
  project       = var.gcp_project_id
  location      = var.gcp_region
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "google_container_cluster" "primary" {
  project                 = var.gcp_project_id
  name                    = var.cluster_name
  location                = var.gcp_region
  network                 = var.network_name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 30
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

   private_cluster_config {
    enable_private_nodes       = true
    master_global_access_config {
      enabled = true
    }
  }

  depends_on = [
    google_storage_bucket.tf_state,
  ]
}

resource "google_container_node_pool" "primary_nodes" {
  project    = var.gcp_project_id
  name       = var.node_pool_name
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 30
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [
    google_container_cluster.primary,
  ]
}
