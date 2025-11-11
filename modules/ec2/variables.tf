variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to launch EC2 instances in"
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH"
  default     = "fares_key"
}

variable "is_public" {
  type        = bool
  description = "Is this EC2 in public subnet (true) or private (false)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EC2 instances will be launched"
}

variable "bastion_ip" {
  type        = string
  description = "Public IP of the bastion/public EC2 to SSH through"
  default     = ""
}
