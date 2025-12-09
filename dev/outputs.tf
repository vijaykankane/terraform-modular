output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnets" { value = module.vpc.public_subnets }
output "private_subnets" { value = module.vpc.private_subnets }
output "s3_endpoint" { value = module.vpc.s3_endpoint }
output "nat_gateway_id" { value = module.vpc.nat_gateway_id }
output "bastion_instance_id" {
  value = module.bastion.bastion_instance_id
}
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
output "target_group_arn" {
  value = module.alb.target_group_arn
}
output "asg_name" {
  value = module.asg_app.asg_name
}