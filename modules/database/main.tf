resource "google_compute_instance" "db_instance" {
    name         = "db-postgres-spot"
    machine_type = "e2-micro"
    zone         = "${var.region}-b"
    
    scheduling {
        preemptible        = true
        automatic_restart  = false
        provisioning_model = "SPOT"
    }

    boot_disk {
        initialize_params { image = "debian-cloud/debian-13" }
    }

    network_interface {
        network = var.vpc_network
        access_config {} 
    }

    metadata_startup_script = <<-EOT
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo docker run --name postgres-db -e POSTGRES_PASSWORD=${var.db_password} -d -p 5432:5432 postgres
    EOT
}