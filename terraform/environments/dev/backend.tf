terraform {
  backend "s3" {
    bucket  = "myapp-terraform-state-bucket123"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
