terraform {
  backend "s3" {
    bucket = "terraform-state-validation-platform-int"
    key    = "simphera.tfstate"
    region = "eu-central-1"
  }
}
