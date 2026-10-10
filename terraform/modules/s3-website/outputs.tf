output "bucket_id" {
  description = "The ID of the S3 website bucket."
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "The ARN of the S3 website bucket."
  value       = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  description = "The website endpoint URL (HTTP only)."
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "bucket_domain_name" {
  description = "The bucket regional domain name."
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "bucket_region" {
  description = "The AWS region the bucket is located in."
  value       = aws_s3_bucket.website.region
}
