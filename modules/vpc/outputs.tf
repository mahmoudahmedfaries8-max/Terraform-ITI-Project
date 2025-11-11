output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = [for s in aws_subnet.public : s.id]
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = [for s in aws_subnet.private : s.id]
  description = "List of private subnet IDs"
}
