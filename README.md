# Sample 3-Tier AWS Architecture with Terraform Modules

A small, readable example of a three-tier network built from local Terraform modules. It is designed for teaching: the modules are generic, and the `dev` environment only supplies inputs.

## Architecture

```
                         Internet
                             |
                      Internet Gateway
                             |
  +--------------------------+--------------------------+
  |  VPC 10.0.0.0/16                                    |
  |                                                     |
  |  WEB TIER   public subnets  (10.0.1.0/24, 10.0.2.0/24)
  |     EC2 + Nginx            <- public IP             |
  |                |                                    |
  |  APP TIER   private subnets (10.0.11.0/24, 10.0.12.0/24)
  |     EC2                    <- no public IP          |
  |                |                                    |
  |  DATA TIER  isolated subnets (10.0.21.0/24, 10.0.22.0/24)
  |     DB subnet group (ready for RDS)   S3 bucket     |
  +-----------------------------------------------------+
```

| Tier | Where it lives | What it contains |
| --- | --- | --- |
| Web | Public subnets | EC2 instance running Nginx with a public IP |
| App | Private subnets | EC2 instance with no public IP |
| Data | Isolated subnets and S3 | DB subnet group for a future RDS instance, plus a private encrypted S3 bucket |

The data tier subnets have no route to the internet. The app tier only gets outbound internet if you enable the NAT Gateway.

## Repository layout

```
terraform/
  modules/
    vpc/              VPC, three subnet tiers, route tables, optional NAT Gateway
    ec2/              Instance, IAM role with SSM access, optional read-only S3 access
    s3/               Private, versioned, encrypted bucket with a TLS-only policy
    security-groups/  Web -> app -> db security group chain (call is commented out)
  environments/
    dev/              Root module: calls the modules with dev inputs
```

All modules are called through relative local paths, for example `source = "../../modules/vpc"`.

## Prerequisites

- Terraform 1.5 or later
- AWS CLI configured with credentials that can create VPC, EC2, IAM and S3 resources
- Session Manager plugin for the AWS CLI, if you want shell access to the instances

## Deploy

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # adjust if needed
terraform init
terraform validate
terraform plan
terraform apply
```

## Connect to the instances

The instances have no SSH keys and no inbound SSH. Use AWS Systems Manager Session Manager:

```bash
aws ssm start-session --target "$(terraform output -raw web_instance_id)"
```

The app instance sits in a private subnet. Session Manager can only reach it if the instance has a route to the SSM service, so set `enable_nat_gateway = true` (or add VPC endpoints for `ssm`, `ssmmessages` and `ec2messages`).

## Security groups are commented out

The `security-groups` module is complete, but its call in `environments/dev/main.tf` is commented out. Until you enable it, both instances use the VPC default security group. That group only allows traffic from members of the same group, so the Nginx page is **not reachable from the internet yet**. This is intentional: students enable it as an exercise.

To enable the tiered security groups:

1. Uncomment the `module "security_groups"` block in `main.tf`.
2. Uncomment the `security_group_ids` line in `module "web"` and in `module "app"`.
3. Uncomment the `security_group_ids` output in `outputs.tf`.
4. Run `terraform plan` and `terraform apply`.

Result: the internet can reach the web tier on ports 80 and 443 (restrict this with `allowed_http_cidrs`), only the web tier can reach the app tier on port 8080, and only the app tier can reach the data tier on port 3306.

## Cost warnings

| Resource | Charged? | Notes |
| --- | --- | --- |
| NAT Gateway | **Yes, hourly plus per GB** | Off by default. Turn on only when needed and destroy afterwards |
| EC2 instances | Yes, per hour | Two `t3.micro` instances. Free Tier eligibility depends on your account and region |
| EBS volumes | Yes, small | Two 8 GiB gp3 root volumes |
| Elastic IP | Only while the NAT Gateway exists | Created and released with the NAT Gateway |
| S3 bucket | Pennies at lab scale | Storage and requests only |
| VPC, subnets, route tables, security groups, IAM | No | |

## Clean up

```bash
cd terraform/environments/dev
terraform destroy
```

The bucket is created with `force_destroy = true` in the dev environment so the destroy works even if you uploaded test objects. After destroying, check the EC2, VPC and S3 consoles to confirm nothing is left, especially the NAT Gateway and its Elastic IP.

## Extending the example

- Add an `rds` module in the data tier using `module.vpc.db_subnet_group_name` and the `db` security group.
- Add an Application Load Balancer in front of the web tier and move the web instance into an Auto Scaling Group.
- Turn on the S3 backend in `providers.tf` and use one state key per environment.
- Copy `environments/dev` to `test` and `prod` and change only the inputs.
