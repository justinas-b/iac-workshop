terraform {
  backend "s3" {
    bucket  = "topic-one-state-017824814810"
    key     = "workshop/all-in-one/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
