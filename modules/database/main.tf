resource "google_service_account" "db_vm" {
  account_id   = "db-postgres-vm"
  display_name = "Service account de la VM Postgres"
}

resource "google_secret_manager_secret_iam_member" "db_vm_secret_access" {
  secret_id = var.db_password_secret
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.db_vm.email}"
}

resource "google_compute_instance" "db_instance" {
  name                = "db-postgres-${var.project_id}"
  machine_type        = "e2-micro"
  zone                = "${var.region}-b"
  deletion_protection = true

  scheduling {
    preemptible        = false
    automatic_restart  = true
    provisioning_model = "STANDARD"
  }

  boot_disk {
    initialize_params { image = "debian-cloud/debian-13" }
  }

  network_interface {
    network    = var.vpc_network
    network_ip = var.db_private_ip
  }

  service_account {
    email  = google_service_account.db_vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    if ! command -v docker >/dev/null 2>&1; then
      apt-get update
      apt-get install -y docker.io
    fi
    systemctl enable --now docker

    mkdir -p /var/lib/postgresql-data

    if [ -z "$(docker ps -aq -f name=postgres-db)" ]; then
      DB_PASSWORD=$(gcloud secrets versions access latest --secret="${var.db_password_secret}" --project="${var.project_id}")
      docker run --name postgres-db \
        --restart unless-stopped \
        -e POSTGRES_PASSWORD="$DB_PASSWORD" \
        -v /var/lib/postgresql-data:/var/lib/postgresql/data \
        -p 5432:5432 \
        -d postgres:16
    fi
  EOT

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_secret_manager_secret_iam_member.db_vm_secret_access]
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
  disk = google_compute_instance.db_instance.name
  zone = google_compute_instance.db_instance.zone
}
