.PHONY: help init plan apply destroy validate fmt clean

# Directory for Terraform environment
TF_DIR := terraform/environments/prodigit-dev

help:
	@echo "AWS 3-Tier Terraform Infrastructure"
	@echo ""
	@echo "Available commands:"
	@echo "  make init       Initialize Terraform (run first)"
	@echo "  make validate   Validate Terraform configuration"
	@echo "  make fmt        Format Terraform code"
	@echo "  make plan       Plan infrastructure changes"
	@echo "  make apply      Apply infrastructure changes"
	@echo "  make destroy    Destroy all infrastructure"
	@echo "  make clean      Remove Terraform state files and cache"
	@echo ""
	@echo "Quick start:"
	@echo "  1. Copy terraform.tfvars: make tfvars"
	@echo "  2. Initialize: make init"
	@echo "  3. Review changes: make plan"
	@echo "  4. Deploy: make apply"
	@echo ""

tfvars:
	@if [ -f $(TF_DIR)/terraform.tfvars ]; then \
		echo "terraform.tfvars already exists"; \
	else \
		cp $(TF_DIR)/terraform.tfvars.example $(TF_DIR)/terraform.tfvars; \
		echo "Created terraform.tfvars from example"; \
		echo "⚠️  Review $(TF_DIR)/terraform.tfvars and adjust as needed"; \
	fi

init: tfvars
	cd $(TF_DIR) && terraform init

validate:
	cd $(TF_DIR) && terraform validate

fmt:
	cd $(TF_DIR) && terraform fmt -recursive ../..

plan: validate
	cd $(TF_DIR) && terraform plan

apply: plan
	cd $(TF_DIR) && terraform apply

destroy:
	@echo "⚠️  WARNING: This will destroy all infrastructure!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds..."
	@sleep 5
	cd $(TF_DIR) && terraform destroy

clean:
	cd $(TF_DIR) && rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
	@echo "Cleaned up Terraform cache and state files"
