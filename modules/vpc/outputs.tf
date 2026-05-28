output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork_name" {
  value = var.vpc_subnetwork
}

output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "subnetwork_id" {
  value = null
}