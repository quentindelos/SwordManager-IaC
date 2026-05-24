# Registry pour les images Docker
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "swordmanager-repo"
  format        = "DOCKER"
}

# --- 1. LE BACKEND ---
resource "google_cloud_run_v2_service" "backend" {
  name     = "swordmanager-backend"
  location = var.region

  template {
    containers {
      # Image temporaire pour l'initialisation Terraform
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      
      env {
        name  = "DB_HOST"
        value = var.db_host_ip
      }
      
      env {
        name  = "DB_PASS"
        value = var.db_password
      }
      
      env {
        name  = "JWT_SECRET"
        value = var.jwt_secret
      }

      # --- Variables ajoutées pour Sequelize ---
      env {
        name  = "DB_USER"
        value = "postgres"
      }

      env {
        name  = "DB_NAME"
        value = "postgres"
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }
    }
  }

  # Ignore les futures images poussées par la CI/CD (GitHub Actions)
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

# Rendre le Backend accessible publiquement
resource "google_cloud_run_service_iam_member" "backend_public" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Mapping DNS pour le Backend (API)
resource "google_cloud_run_domain_mapping" "backend_dns" {
  location = var.region
  name     = "api.${var.domain_name}"
  
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.backend.name
  }
}

# --- 2. LE FRONTEND ---
resource "google_cloud_run_v2_service" "frontend" {
  name     = "swordmanager-frontend"
  location = var.region

  template {
    containers {
      # Image temporaire pour l'initialisation Terraform
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  # Ignore les futures images poussées par la CI/CD (GitHub Actions)
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

# Rendre le Frontend accessible publiquement
resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_v2_service.frontend.location
  service  = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Mapping DNS pour le Frontend (WWW)
resource "google_cloud_run_domain_mapping" "frontend_dns" {
  location = var.region
  name     = "www.${var.domain_name}"
  
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.frontend.name
  }
}