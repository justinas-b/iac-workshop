terraform {
  backend "s3" {
    bucket  = "change-me"
    key     = "workshop/all-in-one/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
