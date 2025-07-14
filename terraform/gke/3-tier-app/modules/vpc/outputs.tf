output "vpc" {
  value = google_compute_network.vpc_network
}

output "backend_subnet" {
  value = google_compute_subnetwork.backend_subnets[0]
}

output "frontend_subnet" {
  value = google_compute_subnetwork.frontend_subnets[0]
}

output "database_subnet" {

  value = google_compute_subnetwork.database_subnets[0]

}
