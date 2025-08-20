
module "frontend" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = var.frontend_sg_name
    sg_description = var.frontend_sg_description
    vpc_id = local.vpc_id
}

module "bastion" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = var.bastion_sg_name
    sg_description = var.bastion_sg_description
    vpc_id = local.vpc_id
}

module "backend_alb" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "backend-alb"
    sg_description = "for backend alb"
    vpc_id = local.vpc_id
}

# 🔍 aws security group rule terraform, i mean ingress
# bastion accepting connection from my laptop, ade miru office lo ite mii network istaru anamata, I mean CIDR

resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.bastion.sg_id 
}

# security_group_id = module.bastion.sg_id, manam terraform-aws-securitygroup module use chesukoni bastion ki oka security create chestunnam, Now roboshop-infra-dev lo sg ane team vallu, terraform-aws-securitygroup ane module use chesukoni sg okka output tisukuntunnaruu. So bastion ee sg_id ni attach chesukovali ante, ee sg_id ni yela evvali.. 

# Backend ALB accepting connections from my bastion host number port 80

resource "aws_security_group_rule" "backend_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.backend_alb.sg_id 
}

# cidr_blocks = ["0.0.0.0/0"] kadu ekkada, either sources security group ina evvali or Cide_blocks ina evvali.. source yekkad nimdi vastumdhi, Traffic source bastion nimdi kada, so i can give bastion 