output "instance_public_ip" {
    description = "O endereço IP público da VM provisionada."
    value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
    description = "O nome da VM provisionada."
    value       = google_compute_instance.vm_instance.name
}
