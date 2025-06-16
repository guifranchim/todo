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

variable "tf_state_bucket_name" {
  description = "O nome do bucket GCS para armazenar o estado do Terraform. Deve ser globalmente único."
  type        = string
  default     = "tf-state-261909652338-bucket"
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

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}


resource "google_storage_bucket" "tf_state" {
  project      = var.gcp_project_id
  name         = var.tf_state_bucket_name
  location     = var.gcp_region
  force_destroy = false 

  
  versioning {
    enabled = true
  }
}


resource "google_container_cluster" "primary" {
  project  = var.gcp_project_id
  name     = var.cluster_name
  location = var.gcp_region
  network  = var.network_name
  remove_default_node_pool = true
  initial_node_count       = 1

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

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
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

terraform {
  backend "gcs" {
    bucket = "tf-state-261909652338-bucket"
    prefix = "gke/todo-ua" 
  }
}
