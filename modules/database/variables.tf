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
  description = "Région de l’instance Cloud SQL"
  type        = string
}

variable "instance_tier" {
  description = "Machine type de l’instance Cloud SQL (ex: db-custom-1-3840)"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données applicative"
  type        = string
}

variable "db_user" {
  description = "Nom de l’utilisateur DB applicatif"
  type        = string
}

variable "private_network_self_link" {
  description = "Self link du VPC privé utilisé par Cloud SQL"
  type        = string
}

variable "deletion_protection" {
  description = "Active la protection de suppression sur l’instance Cloud SQL"
  type        = bool
  default     = true
}
