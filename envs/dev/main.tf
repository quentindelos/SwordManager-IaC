terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Exemple de backend distant (à adapter selon votre organisation)
  # backend "gcs" {
  #   bucket = "my-tf-state-bucket"
  #   prefix = "password-manager/dev"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  environment    = "dev"
  project_prefix = var.project_prefix
}

module "database" {
  source = "../../modules/database"

  project_id               = var.project_id
  project_prefix           = local.project_prefix
  environment              = local.environment
  region                   = var.region
  instance_tier            = var.db_instance_tier
  db_name                  = var.db_name
  db_user                  = var.db_user
  private_network_self_link = var.private_network_self_link
  deletion_protection      = false
}

module "app" {
  source = "../../modules/app"

  project_id            = var.project_id
  project_prefix        = local.project_prefix
  environment           = local.environment
  region                = var.region
  image                 = var.app_image
  db_name               = module.database.db_name
  db_user               = module.database.db_user
  db_password_secret_id = module.database.db_password_secret_id
  db_connection_name    = module.database.instance_connection_name
  service_account_email = var.app_service_account_email
  min_instances         = var.app_min_instances
  max_instances         = var.app_max_instances
}

module "networking" {
  source = "../../modules/networking"

  project_id             = var.project_id
  project_prefix         = local.project_prefix
  environment            = local.environment
  region                 = var.region
  service_name           = local.project_prefix
  cloud_run_service_name = module.app.service_name
  domains                = var.domains
  primary_domain         = var.primary_domain
}

output "cloud_run_url" {
  description = "URL par défaut du service Cloud Run (avant load balancer global)"
  value       = module.app.service_url
}

output "lb_ip_address" {
  description = "IP publique du load balancer global"
  value       = module.networking.lb_ip_address
}

output "lb_url" {
  description = "URL HTTPS du load balancer"
  value       = module.networking.lb_url
}
