terraform {
  backend "gcs" {
    bucket = "swordmanager-terraform-state"
    prefix = "SwordManager/envs/dev"
  }
}