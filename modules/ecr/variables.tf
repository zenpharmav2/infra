variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "repositories" {
  description = "ECR repository names to create"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "keep_image_count" {
  description = "Number of images to keep per repository; older ones are expired"
  type        = number
  default     = 10
}
