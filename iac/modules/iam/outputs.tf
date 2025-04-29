output "instance_profile_name" {
  description = "The IAM Instance Profile name"
  value       = aws_iam_instance_profile.this.name
}

output "role_name" {
  description = "The IAM Role name"
  value       = aws_iam_role.this.name
}
