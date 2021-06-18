output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
output "bastion_sg" {
  value = aws_security_group.bastion.id
}
output "tmp_sg" {
  value = aws_security_group.temp_allow_ssh.id
}