variable "gcp_project_id" {
  description = "O ID do seu projeto GCP."
  type        = string
}

variable "gcp_zone" {
  description = "A ZONA onde os recursos serão criados (não a região)."
  type        = string
  default     = "southamerica-east1-b" 
}

variable "environment" {
  description = "O ambiente de deploy (ex: stage, production)."
  type        = string
}

variable "cluster_name" {
  description = "O nome base para o cluster GKE. O ambiente será sufixado."
  type        = string
  default     = "todo-ua"
}

variable "node_count" {
  description = "O número inicial de nós no node pool."
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "O tipo de máquina para os nós do GKE."
  type        = string
  default     = "e2-medium"
}