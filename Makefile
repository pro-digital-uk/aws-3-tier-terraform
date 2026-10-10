.PHONY: help init plan apply destroy validate fmt clean backend-check check-prereqs

# Directory for Terraform environment
TF_DIR := terraform/environments/prodigit-dev

help:
	@echo "AWS 3-Tier Terraform Infrastructure"
	@echo ""
	@echo "Available commands:"
	@echo "  make tfvars         Copy terraform.tfvars from example"
	@echo "  make backend-check  Verify S3 backend prerequisites"
	@echo "  make init           Initialize Terraform (run first)"
	@echo "  make validate       Validate Terraform configuration"
	@echo "  make fmt            Format Terraform code"
	@echo "  make plan           Plan infrastructure changes"
	@echo "  make apply          Apply infrastructure changes"
	@echo "  make destroy        Destroy all infrastructure"
	@echo "  make clean          Remove Terraform state files and cache"
	@echo ""
	@echo "Backend (Remote State):"
	@echo "  Bucket:      terraform-state-493245399435"
	@echo "  Key:         dev/aws-3-tier"
	@echo "  Region:      eu-west-2"
	@echo "  Locking:     DynamoDB table 'terraform-locks'"
	@echo ""
	@echo "Quick start:"
	@echo "  1. Check backend: make backend-check"
	@echo "  2. Copy tfvars:   make tfvars"
	@echo "  3. Initialize:    make init"
	@echo "  4. Review plan:   make plan"
	@echo "  5. Deploy:        make apply"
	@echo ""
	@echo "Provider versions: AWS >= 5.0"
	@echo ""

tfvars:
	@if [ -f $(TF_DIR)/terraform.tfvars ]; then \
		echo "✓ terraform.tfvars already exists"; \
	else \
		cp $(TF_DIR)/terraform.tfvars.example $(TF_DIR)/terraform.tfvars; \
		echo "✓ Created terraform.tfvars from example"; \
		echo "⚠️  Review $(TF_DIR)/terraform.tfvars and adjust variables as needed"; \
	fi

backend-check:
	@echo "Backend Configuration Check"
	@echo "============================="
	@echo ""
	@echo "Terraform state storage:"
	@echo "  Bucket:  terraform-state-493245399435"
	@echo "  Region:  eu-west-2"
	@echo "  Locking: DynamoDB table 'terraform-locks'"
	@echo ""
	@echo "Before running 'make init', verify:"
	@echo "  ✓ S3 bucket exists: terraform-state-493245399435"
	@echo "  ✓ DynamoDB table exists: terraform-locks (with LockID partition key)"
	@echo "  ✓ AWS credentials have S3 and DynamoDB access"
	@echo ""
	@echo "To check S3 bucket:"
	@echo "  aws s3 ls s3://terraform-state-493245399435/"
	@echo ""
	@echo "To check DynamoDB table:"
	@echo "  aws dynamodb describe-table --table-name terraform-locks --region eu-west-2"
	@echo ""

init: tfvars
	@echo "Initializing Terraform with S3 backend..."
	cd $(TF_DIR) && terraform init

validate:
	@echo "Validating Terraform configuration..."
	cd $(TF_DIR) && terraform validate

fmt:
	@echo "Formatting Terraform code..."
	cd $(TF_DIR) && terraform fmt -recursive ../..
	@echo "✓ Formatting complete"

plan: validate
	@echo ""
	@echo "Planning infrastructure changes..."
	@echo "Review the plan above. To apply, run: make apply"
	@echo ""
	cd $(TF_DIR) && terraform plan

apply: plan
	@echo ""
	@echo "Applying infrastructure changes..."
	cd $(TF_DIR) && terraform apply

destroy:
	@echo ""
	@echo "⚠️  WARNING: This will destroy all AWS infrastructure!"
	@echo "  - EC2 instances will be terminated"
	@echo "  - VPC and subnets will be deleted"
	@echo "  - S3 bucket will be deleted (force_destroy = true in dev)"
	@echo ""
	@echo "Press Ctrl+C to cancel, or wait 5 seconds..."
	@sleep 5
	cd $(TF_DIR) && terraform destroy

clean:
	@echo "Cleaning up local Terraform state and cache..."
	cd $(TF_DIR) && rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
	@echo "✓ Local state cleaned (remote S3 backend state unchanged)"
	@echo ""
	@echo "Note: This does NOT delete the S3 backend or DynamoDB lock table"
	@echo "      Run 'make destroy' first to remove AWS infrastructure"
