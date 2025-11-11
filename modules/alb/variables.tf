variable "vpc_id" {
  type        = string
  description = "The VPC ID where ALBs will be deployed"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for the internal ALB"
}

variable "public_targets" {
  type        = list(string)
  description = "List of public EC2 instance IDs to attach"
}

variable "private_targets" {
  type        = list(string)
  description = "List of private EC2 instance IDs to attach"
}
