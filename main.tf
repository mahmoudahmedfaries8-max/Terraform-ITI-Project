# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC Module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.0.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.1.0/24", "10.0.3.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Public EC2 Proxies
module "public_ec2" {
  source        = "./modules/ec2"
  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_ids    = module.vpc.public_subnets
  key_name      = "fares_key"
  is_public     = true
  vpc_id        = module.vpc.vpc_id
}

# Private EC2 Backends
module "private_ec2" {
  source        = "./modules/ec2"
  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_ids    = module.vpc.private_subnets
  key_name      = "fares_key"
  is_public     = false
  vpc_id        = module.vpc.vpc_id
  bastion_ip    = module.public_ec2.public_ips[0]
}

# ALB Module
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  public_targets  = module.public_ec2.instance_ids
  private_targets = module.private_ec2.instance_ids
}
