

module "vpc" {
  source          = "./../modules/vpc"
  environment     = var.environment
  vpc_cidr        = "10.47.0.0/16"
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.47.1.0/24", "10.47.2.0/24", "10.47.3.0/24"]
  private_subnets = ["10.47.11.0/24", "10.47.12.0/24", "10.47.13.0/24"]
}
module "bastion" {
  source         = "./../modules/bastion"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  key_name       = var.key_name
  environment    = var.environment
}

module "alb" {
  source       = "./../modules/alb"
  vpc_id       = module.vpc.vpc_id
  public_subns = module.vpc.public_subnets
  environment  = var.environment
}

module "asg_app" {
  source        = "./../modules/asg"
  vpc_id        = module.vpc.vpc_id
  private_subns = module.vpc.private_subnets
  alb_tg_arn    = module.alb.target_group_arn
  environment   = var.environment
  key_name      = var.key_name
}