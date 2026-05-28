resource "google_compute_network" "vpc_network" {
  name = var.vpc_network
}

resource "google_compute_firewall" "allow_postgres" {
  name    = "allow-postgres"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = ["0.0.0.0/0"]
}