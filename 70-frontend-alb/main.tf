module "frontend_alb" {
  # offical module kabatti automatic git nimdi tisukumtumdhi, No need to give git::
  source = "terraform-aws-modules/alb/aws"  
  version = "9.16.0"
  internal = false    # <-- we need public applicaton-load-balancer kabatti false
  name    = "${var.project}-${var.environment}-frontend_alb" #roboshop-dev-frontend_alb come on Console 
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_ids
  create_security_group = false     # <-- because we already created SG, kabatti default dhi false ani istam. 
  security_groups =[local.frontend_alb_sg_id] # <-- [] 
  enable_deletion_protection = false 

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend_alb" # name comes on the tags 
    }
  )
}

# 🔍 aws lb listener
resource "aws_lb_listener" "frontend_alb" {
  load_balancer_arn = module.frontend_alb.arn # arn--> amazon resources name, oka single output ID
  port              = "443"  # 80 --> HTTP, 443 --> HTTPS
  protocol          = "HTTPS" 
  ssl_policy        = "ELBSecurityPolicy-2016-08" # <-- Terraform vallu Documention update cheyaledu  
  certificate_arn   = local.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html" # <--
      message_body = "<h1>Hello, I am from Frontend ALB Listener using HTTPS<h1>" # <--
      status_code  = "200"
    }
  }
}

# arn--> amazon resources name, oka single output ID, EC2->Load balancer -> roboshop-dev-backend-alb
# so listener velli load-balancer ki add avutumdhi.. 


# aws record terraform then take alias record example 
resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name    = "${var.environment}.${var.zone_name}"  # <-- dev.daws84s.site,   *.daws84s.site
  type    = "A"

  alias {
    name                   = module.frontend_alb.dns_name
    zone_id                = module.frontend_alb.zone_id   # This is the zone id of ALB Not ours
    evaluate_target_health = true
  }
}