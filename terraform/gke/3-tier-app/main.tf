locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}


provider "google" {
  project = var.project
  region  = var.region
}


resource "google_project_service" "api" {
  for_each = toset(local.apis)
  service  = each.key

  disable_on_destroy = false
}
