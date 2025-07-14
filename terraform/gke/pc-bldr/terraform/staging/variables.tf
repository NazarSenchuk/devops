variable "project" {
  description = "Project ID"
}
variable "region" {
  description = "Region of subnets"
}

variable "backend_name" {
  description = "Name of backend container"
  default     = "gcr.io/daring-chess-382110/backend:1.0"
}

variable "frontend_name" {
  description = "Name of frontend container"
  default     = "gcr.io/daring-chess-382110/frontend:1.3"
}
variable "workspace" {
  description = "Name of workspace"

}
