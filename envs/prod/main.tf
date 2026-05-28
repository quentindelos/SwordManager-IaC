data "google_secret_manager_secret_version" "db_password" {
  secret  = "db-password"
  project = var.project_id
}

data "google_secret_manager_secret_version" "jwt_secret" {
  secret  = "jwt-secret"
  project = var.project_id
}

module "vpc" {
  source         = "../../modules/vpc"
  project_id     = var.project_id
  region         = var.region
  vpc_network    = var.vpc_network
  vpc_subnetwork = var.vpc_subnetwork
}

module "database" {
  source        = "../../modules/database"
  vpc_network   = module.vpc.network_name
  region        = var.region
  db_password   = data.google_secret_manager_secret_version.db_password.secret_data
  project_id    = var.project_id
  db_private_ip = var.db_private_ip
}

module "services" {
  source         = "../../modules/services"
  project_id     = var.project_id
  region         = var.region
  db_host_ip     = var.db_private_ip
  db_password    = data.google_secret_manager_secret_version.db_password.secret_data
  jwt_secret     = data.google_secret_manager_secret_version.jwt_secret.secret_data
  domain_name    = var.domain_name
  vpc_network    = module.vpc.network_name
  vpc_subnetwork = module.vpc.subnetwork_name

}

module "analytics" {
  source     = "../../modules/analytics"
  project_id = var.project_id
}