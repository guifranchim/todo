variable "gcp_project_id" {
    description = "O ID do projeto GCP."
    type        = string
}

variable "gcp_region" {
    description = "A região GCP para os recursos."
    type        = string
    default     = "southamerica-east1" 
}

variable "gcp_zone" {
    description = "A zona GCP para a instância da VM."
    type        = string
    default     = "southamerica-east1-a"
}

variable "instance_name_prefix" {
    description = "Prefixo para o nome da instância da VM."
    type        = string
    default     = "app-vm"
}

variable "environment" {
    description = "Ambiente de deploy (ex: stage, production)."
    type        = string
}

variable "machine_type" {
    description = "O tipo de máquina para a VM."
    type        = string
    default     = "e2-medium"
}

variable "image_project" {
    description = "Projeto da imagem para a VM."
    type        = string
    default     = "ubuntu-os-cloud"
}

variable "image_family" {
    description = "Família da imagem para a VM (ex: ubuntu-2004-lts)."
    type        = string
    default     = "ubuntu-2204-lts"
}

variable "boot_disk_size" {
    description = "Tamanho do disco de boot em GB."
    type        = number
    default     = 20 
}

variable "app_port" {
    description = "Porta em que a aplicação frontend será exposta."
    type        = number
    default     = 80
}

variable "backend_app_port" {
    description = "Porta interna do backend (se diferente e precisar de regra específica)."
    type        = number
    default     = 8080
}

variable "ssh_user" {
    description = "Usuário para SSH na VM."
    type        = string
    default     = "githubactions"
}

variable "ssh_public_key" {
    description = "Conteúdo da chave SSH pública para acesso à VM."
    type        = string
    sensitive   = true
}

variable "network_name" {
    description = "Nome da rede VPC."
    type        = string
    default     = "default"
}
variable "enable_monitoring" {
  description = "Flag para habilitar configuração de monitoramento"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Senha do admin do Grafana"
  type        = string
  sensitive   = true
  default     = "admin"
}