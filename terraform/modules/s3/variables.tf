variable "bucket_name" {
  description = "Globally unique bucket name (3 to 63 lowercase letters, digits and hyphens)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters: lowercase letters, digits and hyphens, starting and ending with a letter or digit."
  }
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a bucket that still contains objects. Keep false in production."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Keep previous versions of overwritten or deleted objects."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key for server-side encryption. Leave null to use S3-managed keys (SSE-S3)."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which old object versions are deleted. Set to 0 to disable the rule."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Extra tags merged onto the bucket."
  type        = map(string)
  default     = {}
}
