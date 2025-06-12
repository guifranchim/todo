# ./variables.tf

variable "gcp_project_id" {
  description = "O ID do projeto GCP."
  type        = string
}

variable "gcp_region" {
  description = "A região GCP para os recursos."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: stage, production)."
  type        = string
  validation {
    condition     = contains(["stage", "production"], var.environment)
    error_message = "O ambiente deve ser 'stage' ou 'production'."
  }
}

variable "cluster_name" {
  description = "Nome base para o cluster GKE."
  type        = string
  default     = "app-cluster"
}

variable "node_count" {
  description = "Número de nós no node pool."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "O tipo de máquina para os nós do GKE."
  type        = string
  default     = "e2-medium"
}

variable "network_name" {
  description = "Nome da rede VPC."
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "Nome da sub-rede VPC."
  type        = string
  default     = "default"
}

# --- Variáveis das Imagens ---
variable "back_repo" {
  description = "Nome do repositório do Artifact Registry para o backend."
  type        = string
}

variable "front_repo" {
  description = "Nome do repositório do Artifact Registry para o frontend."
  type        = string
}

variable "image_repo_back" {
  description = "Nome da imagem do backend."
  type        = string
}

variable "image_repo_front" {
  description = "Nome da imagem do frontend."
  type        = string
}

# --- Variáveis específicas do ambiente ---
variable "env_specifics" {
  description = "Configurações específicas para cada ambiente."
  type = map(object({
    domain             = string
    static_ip_name     = string
    frontend_node_port = number
  }))
  default = {
    stage = {
      domain             = "dev.franch.in"
      static_ip_name     = "ingress-ip-dev"
      frontend_node_port = 30080
    }
    production = {
      domain             = "prod.franch.in"
      static_ip_name     = "ingress-ip-franchin"
      frontend_node_port = 30081
    }
  }
}