variable "project_id" {
  description = "ID du projet GCP cible"
  type        = string
}

variable "project_prefix" {
  description = "Préfixe de nommage pour les ressources (ex: pwdmgr)"
  type        = string
}

variable "region" {
  description = "Région principale GCP (ex: europe-west1)"
  type        = string
}

variable "db_instance_tier" {
  description = "Type de machine Cloud SQL (ex: db-custom-1-3840)"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données applicative"
  type        = string
  default     = "password_manager"
}

variable "db_user" {
  description = "Nom de l’utilisateur applicatif pour la DB"
  type        = string
  default     = "appuser"
}

variable "private_network_self_link" {
  description = "Self link du VPC privé utilisé par Cloud SQL (optionnel si vous utilisez IP publique + Auth Proxy)"
  type        = string
}

variable "app_image" {
  description = "Image container (Artifact Registry) à déployer sur Cloud Run"
  type        = string
}

variable "app_service_account_email" {
  description = "Compte de service utilisé par Cloud Run pour accéder à la DB et aux secrets"
  type        = string
}

variable "app_min_instances" {
  description = "Nombre minimal d’instances Cloud Run"
  type        = number
  default     = 0
}

variable "app_max_instances" {
  description = "Nombre maximal d’instances Cloud Run"
  type        = number
  default     = 3
}

variable "domains" {
  description = "Liste complète des domaines couverts par le certificat HTTPS"
  type        = list(string)
}

variable "primary_domain" {
  description = "Domaine principal utilisé pour l’URL"
  type        = string
}
