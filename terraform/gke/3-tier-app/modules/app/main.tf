
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-database-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


resource "google_sql_database_instance" "db_instance" {
  name             = "database"
  database_version = "POSTGRES_15"

  depends_on = [google_service_networking_connection.private_vpc_connection]


  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}


resource "google_sql_user" "users" {
  name     = var.database_user
  instance = google_sql_database_instance.db_instance.name
  password = var.database_password
}



data "template_file" "backend_init" {
  template = file("${path.module}/startup_scripts/backend.tpl")
  vars = {
    postgres_user     = var.database_user
    postgres_password = var.database_password
    postgres_db       = var.database_name
    postgres_host     = google_sql_database_instance.db_instance.private_ip_address
  }
}


data "template_file" "frontend_init" {
  template = file("${path.module}/startup_scripts/frontend.tpl")
  vars = {
  }
}



resource "google_compute_instance" "backend" {
  name         = "app-backend"
  machine_type = var.instance_type
  zone         = var.zone

  depends_on = [google_sql_database_instance.db_instance]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.vpc.id
    subnetwork = var.backend_subnet.self_link

  }


  tags = ["ssh-enabled"]

  metadata_startup_script = data.template_file.backend_init.rendered
}



resource "google_compute_instance" "frontend" {
  name         = "app-frontend"
  machine_type = var.instance_type
  zone         = var.zone

  depends_on = [google_compute_instance.backend]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.vpc.id
    subnetwork = var.frontend_subnet.self_link
    access_config {

    }
  }

  tags = ["ssh-enabled", "http-enabled"]

  metadata_startup_script = data.template_file.frontend_init.rendered
}
