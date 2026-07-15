variable "region" {
  type = string
}

variable "db_password_secret" {
  type        = string
  description = "ID du secret Secret Manager contenant le mot de passe Postgres (ex: \"db-password\")"
}

variable "vpc_network" {
  type = string
}

variable "project_id" {
  type = string
}

variable "db_private_ip" {
  type = string
}