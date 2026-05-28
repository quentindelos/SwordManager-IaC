resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "${var.project_id}-repo"
  description   = "Depot Docker pour le Backend et Frontend"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "${var.project_id}-backend"
  location = var.region

  template {
    vpc_access {
      network_interfaces {
        network    = var.vpc_network
        subnetwork = var.vpc_subnetwork
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
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

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_service_iam_member" "backend_public" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

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

resource "google_cloud_run_v2_service" "frontend" {
  name     = "${var.project_id}-frontend"
  location = var.region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_v2_service.frontend.location
  service  = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_domain_mapping" "frontend_dns_www" {
  location = var.region
  name     = "www.${var.domain_name}"

  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.frontend.name
  }
}

resource "google_cloud_run_domain_mapping" "frontend_dns_root" {
  location = var.region
  name     = var.domain_name

  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.frontend.name
  }
}