resource "google_compute_instance" "db_instance" {
  name         = "db-postgres-${var.project_id}"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"
  deletion_protection = true

  scheduling {
    preemptible        = true
    automatic_restart  = false
    provisioning_model = "SPOT"
  }

  boot_disk {
    initialize_params { image = "debian-cloud/debian-13" }
  }

  network_interface {
    network    = var.vpc_network
    network_ip = var.db_private_ip
  }

  metadata_startup_script = <<-EOT
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo docker run --name postgres-db -e POSTGRES_PASSWORD=${var.db_password} -d -p 5432:5432 postgres
    EOT

  lifecycle {
    prevent_destroy = true
  }
}