terraform {
  required_version = ">= 1.6.0"
}

locals {
  service_name = var.service_name
}

resource "google_compute_global_address" "default" {
  name         = "${var.project_prefix}-${var.environment}-lb-ip"
  address_type = "EXTERNAL"
  purpose      = "GLOBAL"
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.project_prefix}-${var.environment}-managed-cert"

  managed {
    domains = var.domains
  }
}

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "${var.project_prefix}-${var.environment}-cr-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "${var.project_prefix}-${var.environment}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.project_prefix}-${var.environment}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${var.project_prefix}-${var.environment}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.project_prefix}-${var.environment}-https-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

output "lb_ip_address" {
  description = "IP publique du load balancer"
  value       = google_compute_global_address.default.address
}

output "lb_url" {
  description = "URL HTTPS principale"
  value       = "https://${var.primary_domain}"
}
