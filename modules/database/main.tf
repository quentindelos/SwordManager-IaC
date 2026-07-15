resource "google_compute_instance" "db_instance" {
  name         = "db-postgres-${var.project_id}"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"
  deletion_protection = true

  scheduling {
    preemptible        = true
    automatic_restart  = true
    provisioning_model = "Standard"
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

resource "google_compute_resource_policy" "db_snapshot_policy" {
  name   = "db-daily-snapshot-policy"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "03:00"
      }
    }

    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = ["eu"]
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "db_snapshot_attach" {
  name = google_compute_resource_policy.db_snapshot_policy.name
  disk = google_compute_instance.db_instance.boot_disk[0].source
  zone = "${var.region}-b"
}
