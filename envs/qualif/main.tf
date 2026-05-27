data "google_secret_manager_secret_version" "db_password" {
    secret  = "db-password"
    project = var.project_id
}

data "google_secret_manager_secret_version" "jwt_secret" {
    secret  = "jwt-secret"
    project = var.project_id
}

module "vpc" {
    source = "../../modules/vpc"
}

module "database" {
    source      = "../../modules/database"
    vpc_network = module.vpc.network_name
    region      = var.region
    db_password = data.google_secret_manager_secret_version.db_password.secret_data 
}

module "services" {
    source       = "../../modules/services"
    project_id   = var.project_id
    region       = var.region
    db_host_ip   = module.database.db_public_ip
    db_password  = data.google_secret_manager_secret_version.db_password.secret_data
    jwt_secret   = data.google_secret_manager_secret_version.jwt_secret.secret_data
    domain_name  = var.domain_name
}

module "analytics" {
    source     = "../../modules/analytics"
    project_id = var.project_id
}