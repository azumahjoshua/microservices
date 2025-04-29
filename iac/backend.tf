terraform {
  backend "s3" {
    bucket = "tech4devfinalproject202502040"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
}
