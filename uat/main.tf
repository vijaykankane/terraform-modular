

module "vpc" {
  source          = "./../modules/vpc"
  environment     = var.environment
  vpc_cidr        = "10.47.0.0/16"
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.47.1.0/24", "10.47.2.0/24", "10.47.3.0/24"]
  private_subnets = ["10.47.11.0/24", "10.47.12.0/24", "10.47.13.0/24"]
}