module "vpc" {
  source         = "../../modules/vpc"
  project_id     = var.project_id
  region         = var.region
  vpc_network    = var.vpc_network
  vpc_subnetwork = var.vpc_subnetwork
}

module "database" {
  source             = "../../modules/database"
  vpc_network        = module.vpc.network_name
  region             = var.region
  db_password_secret = "db-password"
  project_id         = var.project_id
  db_private_ip      = var.db_private_ip
}

module "services" {
  source             = "../../modules/services"
  project_id         = var.project_id
  region             = var.region
  db_host_ip         = var.db_private_ip
  db_password_secret = "db-password"
  jwt_secret_id      = "jwt-secret"
  domain_name        = var.domain_name
  vpc_network        = module.vpc.network_name
  vpc_subnetwork     = module.vpc.subnetwork_name
}

module "analytics" {
  source     = "../../modules/analytics"
  project_id = var.project_id
}