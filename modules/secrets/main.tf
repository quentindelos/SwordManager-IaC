resource "google_secret_manager_secret" "secrets" {
  for_each = local.secrets

  secret_id = each.key

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = false
  }

}

resource "google_secret_manager_secret_version" "secrets_versions" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value.secret_data
}
