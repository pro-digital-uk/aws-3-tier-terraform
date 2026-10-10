terraform {
  backend "s3" {
    bucket         = "terraform-state-493245399435"
    key            = "test/aws-3-tier/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
