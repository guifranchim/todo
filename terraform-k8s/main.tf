terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_container_cluster" "primary" {
  project                = var.gcp_project_id
  name                   = "${var.cluster_name}-${var.environment}" 
  location               = var.gcp_region
  remove_default_node_pool = true
  initial_node_count     = 1
  deletion_protection    = false 

  node_config {
    disk_size_gb = 20
  }
}

resource "google_container_node_pool" "primary_nodes" {
  project    = var.gcp_project_id
  name       = "default-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 20
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}


resource "google_artifact_registry_repository" "backend_repo" {
  provider     = google
  project      = var.gcp_project_id
  location     = "us" 
  repository_id = "todolist-backend-repo-${var.environment}"
  description  = "Docker repository for backend - ${var.environment}"
  format       = "DOCKER"
}

resource "google_artifact_registry_repository" "frontend_repo" {
  provider     = google
  project      = var.gcp_project_id
  location     = "us"
  repository_id = "todolist-frontend-repo-${var.environment}"
  description  = "Docker repository for frontend - ${var.environment}"
  format       = "DOCKER"
}