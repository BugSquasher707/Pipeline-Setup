output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

output "security_group_ids" {
  description = "List of security group IDs"
  value = [
    aws_security_group.main.id
  ]
}