variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "db_host_ip" {
  type = string
}

variable "db_password_secret" {
  type        = string
  description = "ID du secret Secret Manager contenant le mot de passe Postgres (ex: \"db-password\")"
}

variable "jwt_secret_id" {
  type        = string
  description = "ID du secret Secret Manager contenant le JWT secret (ex: \"jwt-secret\")"
}

variable "vpc_network" {
  type = string
}

variable "vpc_subnetwork" {
  type = string
}