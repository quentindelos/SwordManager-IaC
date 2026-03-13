variable "environment" {
  type = string
}

variable "ssl_certificate_domains" {
  type        = map(any)
  description = "Map of LB SSL certificate names to domain lists"
}

variable "project_id" {
  type = string
}

