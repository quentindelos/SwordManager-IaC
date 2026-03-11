variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "project_prefix" {
  description = "Préfixe de nommage pour les ressources"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, qualif, prod)"
  type        = string
}

variable "region" {
  description = "Région principale"
  type        = string
}

variable "service_name" {
  description = "Nom logique du service applicatif"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Nom du service Cloud Run à publier"
  type        = string
}

variable "domains" {
  description = "Liste complète des domaines couverts par le certificat"
  type        = list(string)
}

variable "primary_domain" {
  description = "Domaine principal utilisé pour l’URL"
  type        = string
}
