locals {
    protocol = "tcp"
    tags     = ["web-server"]
    domains  = "swordmanager.eu"
    ssl_certificate = {
    dev = {
      "web-front-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["dev.lamie-mutuelle.com"]
        }
      }
      "web-back-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["dev-strapi.lamie-mutuelle.com"]
        }
      }
      "api-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["api-dev.lamie-mutuelle.com"]
        }
      }
    }

    qualif = {
      "web-front-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["recette.lamie-mutuelle.com"]
        }
      }
      "web-back-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["recette-strapi.lamie-mutuelle.com"]
        }
      }
      "api-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["api.staging.lamie-mutuelle.com"]
        }
      }
    }

    prod = {
      "web-front-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["www.lamie-mutuelle.com"]
        }
      }
      "web-back-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["admin.lamie-mutuelle.com"]
        }
      }
      "api-ssl-cert-${var.environment}" = {
        managed = {
          domains = ["api.lamie-mutuelle.com"]
        }
      }
    }
  }
}