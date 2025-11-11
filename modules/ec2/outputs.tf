output "instance_ids" {
  value = [for i in aws_instance.ec2_instances : i.id]
}

output "public_ips" {
  value = [for i in aws_instance.ec2_instances : i.public_ip]
}

output "private_ips" {
  value = [for i in aws_instance.ec2_instances : i.private_ip]
}
