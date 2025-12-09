output "bastion_instance_id" {
  value = aws_instance.bastion.public_ip
}