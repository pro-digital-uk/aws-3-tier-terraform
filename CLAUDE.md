# Project: AWS 3-Tier Terraform Infrastructure

## Overview
This is an educational Terraform project demonstrating a production-ready three-tier AWS network architecture (web, app, data tiers) using composable local modules.

## Architecture
- **Web Tier**: Public subnets with Nginx EC2 instances and public IPs
- **App Tier**: Private subnets with EC2 instances (commented out for students to enable)
- **Data Tier**: Isolated subnets with DB subnet group and encrypted S3 bucket
- **Security**: Tiered security groups controlling traffic flow between tiers

## Key Design Decisions
- **Learning-first**: Security groups and app tier are intentionally commented out as exercises
- **Local modules**: All modules use relative paths (`../../modules/`) for portability
- **Session Manager**: No SSH keys embedded; uses AWS Systems Manager for secure access
- **S3 asset bucket**: Private, versioned, encrypted for storing application data
- **NAT Gateway**: Optional and disabled by default (cost warning: hourly charges apply)
- **Tagging Strategy**: All AWS resources automatically tagged with Project, Team, Environment, and ManagedBy

## When Making Changes

### Adding Features
- Keep modules focused and reusable
- Update `terraform/environments/prodigit-dev/` with new module calls
- Add corresponding variables and outputs
- Document cost implications if applicable

### Extending for Production
- Copy `prodigit-dev/` to `prod/` or `staging/` and adjust inputs only
- Consider S3 backend state management per environment
- Add Application Load Balancer in front of web tier
- Implement Auto Scaling Groups for web and app tiers
- Add RDS database in the data tier using the ready-made DB subnet group

### Keeping App Tier Commented
- The app tier module is intentionally commented out as a teaching exercise
- Students should uncomment it themselves and fix the security group configuration
- Outputs for app tier (instance_id, private_ip) are also commented out

## Resource Tagging

All AWS resources automatically receive consistent tags via the provider's `default_tags` block:

| Tag | Purpose | Source |
| --- | --- | --- |
| `Name` | Environment-specific identifier | `var.environment_name` (e.g. `mupando-dev`, `supando-dev`) |
| `Project` | Project identifier | `var.project_name` (default: `three-tier`) |
| `Team` | Responsible team/department | `var.team_name` (default: `platform`) |
| `Environment` | Deployment environment | `var.environment` (dev/test/prod) |
| `ManagedBy` | Infrastructure as Code tool | Always `terraform` |

Override tags in `terraform.tfvars`:
```hcl
environment_name = "mupando-dev"  # Use your environment name here
project_name     = "my-project"
team_name        = "backend-team"
environment      = "dev"
```

These tags enable cost allocation, automated compliance scanning, and resource organization in the AWS console.

## Remote State (S3 Backend)

Terraform state is stored remotely in S3 for team collaboration and state locking:

**Configuration**: `terraform/environments/prodigit-dev/backend.tf`
- **Bucket**: `terraform-state-493245399435`
- **Key**: `dev/aws-3-tier`
- **Locking**: DynamoDB table `terraform-locks` (prevents concurrent modifications)
- **Encryption**: Enabled

**To Activate Remote State**:
```bash
cd terraform/environments/prodigit-dev
terraform init
```

When you run `terraform init`:
1. Terraform downloads required providers
2. Connects to the S3 backend bucket
3. Initializes state storage if this is the first deploy
4. Sets up state locking with DynamoDB

**Important**: Ensure the S3 bucket and DynamoDB table exist before running `terraform init`:
```bash
# Verify S3 bucket
aws s3 ls s3://terraform-state-493245399435/

# Verify DynamoDB table
aws dynamodb describe-table --table-name terraform-locks --region eu-west-2
```

## Deploying
```bash
cd terraform/environments/prodigit-dev
terraform init
terraform plan
terraform apply
```

## Cost Management
- **NAT Gateway**: Disabled by default (hourly + per-GB charges)
- **EC2 instances**: t3.micro (eligible for Free Tier on new accounts)
- **EBS volumes**: 8 GiB gp3 per instance
- **S3 bucket**: Minimal cost at lab scale
- **VPC components**: No charge

Always run `terraform destroy` to clean up lab resources, especially the NAT Gateway.

## GitHub Prep
- Repository is ready for GitHub push
- Main branch is `main` (changed from `master`)
- Include `.gitignore` to exclude Terraform state files and credentials
- All modules are self-contained and can be versioned independently
