resource "google_bigquery_dataset" "swordmanager_analytics" {
  dataset_id                  = "swordmanager_logs_analytics"
  friendly_name               = "SwordManager Analytics"
  description                 = "Logs du projet de fin d'année"
  location                    = "EU"
  delete_contents_on_destroy  = false
}