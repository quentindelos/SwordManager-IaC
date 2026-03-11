project_id  = "votre-projet-gcp-dev"
project_prefix = "pwdmgr"
region      = "europe-west1"

db_instance_tier        = "db-custom-1-3840"
private_network_self_link = "projects/your-project/global/networks/your-vpc" # à adapter ou laisser vide si non utilisé

app_image                = "europe-west1-docker.pkg.dev/votre-projet-gcp-dev/pwdmgr-dev-app/password-manager:latest"
app_service_account_email = "cloud-run-pwdmgr-dev@votre-projet-gcp-dev.iam.gserviceaccount.com"
app_min_instances        = 0
app_max_instances        = 3

domains = [
  "dev.password-manager.example.com",
]

primary_domain = "dev.password-manager.example.com"
