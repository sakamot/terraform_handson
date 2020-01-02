terraform {
  required_version = "= 0.12.6"
  backend "local" {
    path = "state/terraform.tfstate"
  }
}
