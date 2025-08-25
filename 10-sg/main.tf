
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

module "vpn" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "vpn"
    sg_description = "for vpn"
    vpc_id = local.vpc_id
}

module "mongodb" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "mongodb"
    sg_description = "for mongodb"
    vpc_id = local.vpc_id
}

module "redis" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "redis"
    sg_description = "for redis"
    vpc_id = local.vpc_id
}

module "mysql" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "mysql"
    sg_description = "for mysql"
    vpc_id = local.vpc_id
}

module "rabbitmq" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "rabbitmq"
    sg_description = "for rabbitmq"
    vpc_id = local.vpc_id
}

module "catalogue" {
    #source = "../../terraform-aws-securitygroup"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    
    sg_name = "catalogue"
    sg_description = "for catalogue"
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

resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# backend ALB accepting connections from my VPN host on port no 80
resource "aws_security_group_rule" "backend_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.backend_alb.sg_id 
}

# Mongodb accepting connections from my VPN host on port no 22, 27017
resource "aws_security_group_rule" "mongodb_vpn_ssh" {
  count =length(var.mongdb_ports_vpn)
  type              = "ingress"
  from_port         = var.mongdb_ports_vpn[count.index]
  to_port           = var.mongdb_ports_vpn[count.index]
  protocol          = "tcp"    # 👉 ssh is part of TCP protocol only. 
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.mongodb.sg_id 
}

/* # backend ALB accepting connections freom my VPN host on port no 80
resource "aws_security_group_rule" "mongodb_vpn" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"  
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.mongodb.sg_id 
} */

# redis accepting connections from my VPN host on port no: 6379
resource "aws_security_group_rule" "redis_vpn_ssh" {
  count =length(var.redis_ports_vpn)
  type              = "ingress"
  from_port         = var.redis_ports_vpn[count.index]
  to_port           = var.redis_ports_vpn[count.index]
  protocol          = "tcp"    # 👉 ssh is part of TCP protocol only. 
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.redis.sg_id 
}

# mysql accepting connections from my VPN host on port no 3306
resource "aws_security_group_rule" "mysql_vpn_ssh" {
  count =length(var.mysql_ports_vpn)
  type              = "ingress"
  from_port         = var.mysql_ports_vpn[count.index]
  to_port           = var.mysql_ports_vpn[count.index]
  protocol          = "tcp"    # 👉 ssh is part of TCP protocol only. 
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.mysql.sg_id 
}

# Rabbitmq accepting connections from my VPN host on port no :5672
# opened as part of some jira-321 from DB team
resource "aws_security_group_rule" "rabbitmq_vpn_ssh" {
  count =length(var.rabbitmq_ports_vpn)
  type              = "ingress"
  from_port         = var.rabbitmq_ports_vpn[count.index]
  to_port           = var.rabbitmq_ports_vpn[count.index]
  protocol          = "tcp"    # 👉 ssh is part of TCP protocol only. 
  source_security_group_id = module.vpn.sg_id
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block] No need for US
  security_group_id = module.rabbitmq.sg_id 
}