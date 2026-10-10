output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address, or an empty string when none was assigned."
  value       = aws_instance.this.public_ip
}

output "iam_role_name" {
  description = "Name of the IAM role attached through the instance profile."
  value       = aws_iam_role.this.name
}

output "ami_id" {
  description = "AMI the instance was launched from."
  value       = local.ami_id
}
