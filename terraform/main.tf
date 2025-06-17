terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_compute_address" "vm_static_ip" {
  project = var.gcp_project_id
  name    = "vm-ip-${var.environment}"
  region  = var.gcp_region
}

resource "google_compute_instance" "vm_instance" {
  project      = var.gcp_project_id
  zone         = var.gcp_zone
  name         = "${var.instance_name_prefix}-${var.environment}"
  machine_type = var.machine_type
  tags         = ["http-server", "ssh", "app-${var.environment}"]

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network = var.network_name
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  service_account {
    email  = "default" 
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
  depends_on = [
    google_artifact_registry_repository.backend_repo,
    google_artifact_registry_repository.frontend_repo
  ]
}

resource "google_compute_firewall" "allow_ssh" {
  project       = var.gcp_project_id
  name          = "allow-ssh-vm-${var.environment}"
  network       = var.network_name
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_app_traffic" {
  project       = var.gcp_project_id
  name          = "allow-app-traffic-vm-${var.environment}"
  network       = var.network_name
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports = [
      "80",   
      "8080", 
      "3000", 
      "9090",
      "3001",
      "9091"
    ]
  }
  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["http-server"]
}

resource "google_artifact_registry_repository" "backend_repo" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = "todolist-backend-repo-vm-${var.environment}"
  description   = "Docker repository for VM backend - ${var.environment}"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "frontend_repo" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = "todolist-frontend-repo-vm-${var.environment}"
  description   = "Docker repository for VM frontend - ${var.environment}"
  format        = "DOCKER"
}