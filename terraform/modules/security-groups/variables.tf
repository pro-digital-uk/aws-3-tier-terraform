variable "name" {
  description = "Name prefix for the security groups."
  type        = string
}

variable "vpc_id" {
  description = "VPC the security groups are created in."
  type        = string
}

variable "allowed_http_cidrs" {
  description = "CIDR ranges allowed to reach the web tier on ports 80 and 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port the app tier listens on. Only the web tier may connect."
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port the data tier listens on. Only the app tier may connect."
  type        = number
  default     = 3306
}

variable "tags" {
  description = "Extra tags merged onto every security group."
  type        = map(string)
  default     = {}
}
