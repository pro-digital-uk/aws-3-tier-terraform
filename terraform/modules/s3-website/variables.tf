variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting."
  type        = string
}

variable "website_name" {
  description = "Name displayed on the static website."
  type        = string
}

variable "environment" {
  description = "Environment displayed on the static website."
  type        = string
}

variable "index_document" {
  description = "Name of the index document (default page)."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Name of the error document (404 page)."
  type        = string
  default     = "error.html"
}

variable "enable_versioning" {
  description = "Enable S3 versioning for the website bucket."
  type        = bool
  default     = false
}

variable "upload_index_document" {
  description = "Whether to upload the index document from the provided path."
  type        = bool
  default     = true
}

variable "index_document_path" {
  description = "Path to the index.html file to upload to the bucket."
  type        = string
  default     = ""
}

variable "allowed_principal_org_id" {
  description = "AWS Organization ID to allow public access. If null, allows all principals (fully public)."
  type        = string
  default     = null
}
