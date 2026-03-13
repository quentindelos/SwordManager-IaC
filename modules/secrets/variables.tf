variable "secrets" {
  description = "Map des secrets à injecter dans Secret Manager"
  type        = map(string)
}

variable "environment" {
  description = "Environnement de travail (dev, qualif, prod)"
  type        = string
}