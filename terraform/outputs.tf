output "instance_public_ip" {
    description = "O endereço IP público da VM provisionada."
    value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
    description = "O nome da VM provisionada."
    value       = google_compute_instance.vm_instance.name
}

output "gke_cluster_name" {
  description = "O nome do cluster GKE provisionado."
  value       = google_container_cluster.primary.name
}

output "ingress_ip" {
  description = "O endereço IP público do Ingress. Pode levar alguns minutos para ser alocado."
  value       = kubernetes_ingress_v1.frontend_ingress.status[0].load_balancer[0].ingress[0].ip
}

variable "image_tag" {
  description = "A tag da imagem Docker a ser implantada (ex: o SHA do commit)."
  type        = string
  default     = "latest"
}