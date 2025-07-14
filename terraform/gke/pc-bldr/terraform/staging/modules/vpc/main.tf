resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = "${var.workspace}-${var.vpc_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "frontend_subnets" {
  count         = var.number_of_frontend_subnets
  name          = "${var.workspace}-frontend${count.index}"
  ip_cidr_range = "10.0.${count.index + 1}.0/24"
  region        = var.subnet_region
  network       = google_compute_network.vpc_network.id
  project       = var.project
}

resource "google_compute_subnetwork" "backend_subnets" {
  count         = var.number_of_backend_subnets
  name          = "${var.workspace}-backend${count.index}"
  ip_cidr_range = "10.0.${count.index + 11}.0/24"
  region        = var.subnet_region
  network       = google_compute_network.vpc_network.id
  project       = var.project
}

resource "google_compute_subnetwork" "database_subnets" {
  count         = var.number_of_database_subnets
  name          = "${var.workspace}-database${count.index}"
  ip_cidr_range = "10.0.${count.index + 21}.0/24"
  region        = var.subnet_region
  network       = google_compute_network.vpc_network.id
  project       = var.project
}

resource "google_compute_router" "router" {
  project = var.project
  name    = "${var.workspace}-router"
  network = "${var.workspace}-${var.vpc_name}"
  region  = var.subnet_region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.workspace}-nat"
  project                            = var.project
  router                             = google_compute_router.router.name
  region                             = var.subnet_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Restrict this to your IP for security
  target_tags   = ["ssh-enabled"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Restrict this to your IP for security
  target_tags   = ["http-enabled"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"] # Restrict this to your IP for security
  target_tags   = ["https-enabled"]
}





resource "google_compute_firewall" "allow_internal_services" {
  name        = "allow-internal-services"
  description = "Allow internal traffic between services in VPC"
  network     = google_compute_network.vpc_network.id
  direction   = "INGRESS" # Explicitly set direction (optional but recommended)

  #

  allow {
    protocol = "tcp"
    ports    = ["8000"] # HTTP/API ports grouped
  }
  # Security improvements:
  source_ranges = ["10.0.0.0/16"] # Your VPC range
  target_tags   = ["backend"]
}
