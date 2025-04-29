# ======================
# VPC
# ======================
module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "finalprojectvpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ======================
# IAM
# ======================

module "jenkins_ec2_iam" {
  source      = "./modules/iam"
  role_name   = "jenkins-ec2-role"
  policy_name = "jenkins-ec2-ecr-policy"
}

# ======================
# Jenkins Security Group
# ======================

module "security_group" {
  source ="./modules/security_group"
  sg_name = "jenkins_sg"
  sg_description ="Allow SSH"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "Jenkins_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.security_group.security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH from anywhere"
}


resource "aws_security_group_rule" "Jenkins_ingress_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.security_group.security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Jenkins HTTP access from anywhere"
}

resource "aws_security_group_rule" "jenkins_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = module.security_group.security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# ======================
# Compute Resources
# ======================

module "jenkins_servers" {
  source               = "./modules/ec2"
  instance_count       = 1
  instance_name        = "jenkins-server"
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = "t3.medium"
  key_pair_name        = "finalprojectkey"
  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [module.security_group.security_group_id]
  iam_instance_profile   = module.jenkins_ec2_iam.instance_profile_name
  enable_public_ip     = true  # Jenkins needs public access

  tags = {
    Project     = "FinalProject"
    Environment = "Dev"
    Role        = "Jenkins"
  }
}



# ======================
# ECR Repositories
# ======================

module "go_ecr" {
  source      = "./modules/ecr"
  name        = "go-service-repo"
  description = "ECR repo for go application"
  providers = {
    aws.ecr-public = aws.ecr-public
  }
}

module "rails_ecr" {
  source      = "./modules/ecr"
  name        = "rails-service-repo"
  description = "ECR repo for rails application"
  providers = {
    aws.ecr-public = aws.ecr-public
  }
}

module "flask_ecr" {
  source      = "./modules/ecr"
  name        = "python-service-repo"
  description = "ECR repo for flask application"
  providers = {
    aws.ecr-public = aws.ecr-public
  }
}

# ======================
# EKS
# ======================