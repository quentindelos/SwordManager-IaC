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
  description = "Région d’exécution du service Cloud Run"
  type        = string
}

variable "image" {
  description = "Image container à déployer (Artifact Registry)"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_user" {
  description = "Nom de l’utilisateur DB"
  type        = string
}

variable "db_password_secret_id" {
  description = "ID du secret Secret Manager contenant le mot de passe DB"
  type        = string
}

variable "db_connection_name" {
  description = "Nom de connexion Cloud SQL (project:region:instance)"
  type        = string
}

variable "service_account_email" {
  description = "Compte de service utilisé par Cloud Run"
  type        = string
}

variable "min_instances" {
  description = "Nombre minimal d’instances Cloud Run"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Nombre maximal d’instances Cloud Run"
  type        = number
  default     = 3
}
