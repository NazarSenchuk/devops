output "ip_backend" {
  value = "Private frontend ip: ${google_compute_instance.backend.network_interface.0.network_ip} "
}

output "ip_frontend" {
  value = "Private frontend ip: ${google_compute_instance.frontend.network_interface.0.network_ip} Public ip: ${google_compute_instance.frontend.network_interface.0.access_config.0.nat_ip}"
}

output "ip_database" {
  value = "Private database ip: ${google_compute_global_address.private_ip_address.name} "
}
