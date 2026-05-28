output "db_public_ip" {
  value = google_compute_instance.db_instance.network_interface[0].network_ip
}