variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_network" {
  type = string
}

variable "vpc_subnetwork" {
  type = string
}

variable "subnetwork_cidr" {
  type    = string
  default = "10.0.0.0/24"
}