resource "google_compute_network" "vpc_network" {
  name = var.vpc_network
}

data "google_compute_subnetwork" "vpc_subnetwork" {
  name    = var.vpc_subnetwork
  region  = var.region
  project = var.project_id

  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_router" "router" {
  name    = "${var.vpc_network}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_network}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_postgres" {
  name    = "allow-postgres-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = [data.google_compute_subnetwork.vpc_subnetwork.ip_cidr_range]
}