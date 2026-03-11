terraform {
  required_version = ">= 1.6.0"
}

locals {
  service_name = "${var.project_prefix}-${var.environment}-password-manager"
}

resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "${var.project_prefix}-${var.environment}-app"
  description   = "Registry pour l’image du gestionnaire de mots de passe"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "app" {
  name     = local.service_name
  location = var.region

  template {
    containers {
      image = var.image

      env {
        name  = "DB_HOST"
        value = "127.0.0.1"
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "DB_USER"
        value = var.db_user
      }

      env {
        name = "DB_PASSWORD"

        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_CONNECTION_NAME"
        value = var.db_connection_name
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    service_account = var.service_account_email

    annotations = {
      "run.googleapis.com/cloudsql-instances" = var.db_connection_name
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_v2_service_iam_member" "invoker_all" {
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_name" {
  description = "Nom du service Cloud Run"
  value       = google_cloud_run_v2_service.app.name
}

output "service_url" {
  description = "URL par défaut du service Cloud Run"
  value       = google_cloud_run_v2_service.app.uri
}

output "artifact_registry_repository" {
  description = "Chemin du repository Artifact Registry"
  value       = google_artifact_registry_repository.app_repo.repository_id
}
