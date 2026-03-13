terraform {
  required_version = ">= 1.6.0"
}

resource "google_sql_database_instance" "this" {
  name             = "${var.project_prefix}-${var.environment}-pg"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.instance_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_self_link
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
}

resource "random_password" "db_user_password" {
  length           = 32
  special          = true
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  password = random_password.db_user_password.result
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_user_password.result
}

output "instance_connection_name" {
  description = "Nom de connexion Cloud SQL (pour Cloud Run)"
  value       = google_sql_database_instance.this.connection_name
}

output "db_name" {
  description = "Nom de la base de données applicative"
  value       = google_sql_database.app_db.name
}

output "db_user" {
  description = "Nom de l’utilisateur applicatif"
  value       = google_sql_user.app_user.name
}

output "db_password_secret_id" {
  description = "ID du secret contenant le mot de passe de l’utilisateur DB"
  value       = google_secret_manager_secret.db_password.id
}
