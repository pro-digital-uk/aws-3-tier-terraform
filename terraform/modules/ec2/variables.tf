variable "name" {
  description = "Name of the instance, also used to name its IAM role and profile."
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instance into."
  type        = string
}

variable "ami_id" {
  description = "AMI to use. Leave null to use the latest Amazon Linux 2023 x86_64 image."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip_address" {
  description = "Give the instance a public IP. Only useful in a public subnet."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Security groups to attach. When empty, the VPC default security group is used."
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data script run at first boot."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8
}

variable "s3_bucket_arns" {
  description = "Buckets the instance may read from (GetObject and ListBucket). Empty means no S3 access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}
