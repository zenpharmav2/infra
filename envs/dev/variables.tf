variable "db_password" {
  description = "Master password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 128 && !can(regex("[/@\" ]", var.db_password))
    error_message = "db_password must be 8-128 characters and must not contain /, @, \" or spaces (RDS restriction)."
  }
}

variable "jwt_secret" {
  description = "JWT signing secret for the application"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub username or organization that owns frontend and backend"
  type        = string
  default     = "zenpharmav2"
}