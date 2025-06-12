# ./main.tf

terraform {
  backend "gcs" {
    bucket = "tf-state-261909652337-bucket" # Mantenha seu bucket de estado do Terraform
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Cria o cluster GKE onde as aplicações serão implantadas
resource "google_container_cluster" "primary" {
  project                  = var.gcp_project_id
  name                     = "${var.cluster_name}-${var.environment}"
  location                 = var.gcp_region
  initial_node_count       = 1
  remove_default_node_pool = true

  network    = var.network_name
  subnetwork = var.subnetwork_name

  # Habilita componentes necessários para o Ingress do GKE
  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  # Habilita políticas de rede (Network Policies)
  network_policy {
    enabled = true
  }
}

# Cria um node pool dedicado para as aplicações
resource "google_container_node_pool" "primary_nodes" {
  project    = var.gcp_project_id
  name       = "${var.cluster_name}-node-pool-${var.environment}"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = var.machine_type
    service_account = "projects/${var.gcp_project_id}/serviceAccounts/compute@developer.gserviceaccount.com" # Use uma service account apropriada
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Configura o provedor do Kubernetes para se autenticar no cluster GKE criado
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# Obtém as credenciais de autenticação para o provedor Kubernetes
data "google_client_config" "default" {}