provider "google" {
  project = var.gcp_project_id
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
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }


  service_account {
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_firewall" "allow_http" {
  project = var.gcp_project_id
  name    = "allow-http-${var.environment}"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = [var.app_port]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  project = var.gcp_project_id
  name    = "allow-ssh-${var.environment}"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_backend_app" {
  count   = var.backend_app_port != var.app_port ? 1 : 0
  project = var.gcp_project_id
  name    = "allow-backend-app-${var.environment}"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = [var.backend_app_port]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
resource "google_compute_firewall" "allow_grafana" {
  project = var.gcp_project_id
  name    = "allow-grafana-${var.environment}"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_prometheus" {
  project = var.gcp_project_id
  name    = "allow-prometheus-${var.environment}"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

terraform {
  backend "gcs" {
    bucket = "tf-state-261909652337-bucket"
  }
}
