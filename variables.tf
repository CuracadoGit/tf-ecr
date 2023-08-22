variable "name" {
  type        = string
  description = "The name for the ECR"
}

variable "read_principal_arns" {
  type        = list(string)
  description = "ARNs of principals (e.g. a task execution role) that will be granted permission to read from the ECR"
}

variable "write_principal_arns" {
  type        = list(string)
  description = "ARNs of principals (e.g. automation user) that will be granted write access in order to push new images"
}

variable "scan_on_push" {
  type        = bool
  description = "Scan images on push"
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key that will be used to encrypt images"
}

variable "keep_last_images" {
  type        = number
  default     = 10
  description = "Restrict the number of images to the latest x"
}

variable "image_tag_mutability" {
  type    = bool
  default = false
}