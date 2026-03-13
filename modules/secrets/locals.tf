locals {
  secrets = {
    for name, value in var.secrets :
    "${name}-${var.environment}" => {
      secret_data = value
    }
  }
}