module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"

  name = "John Doe"

  force_destroy           = true
  password_reset_required = false

  tags = {
    Created-by  = "Terraform"
    Environment = "dev"
    
  }
}
