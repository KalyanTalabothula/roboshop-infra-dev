module "backend_alb" {
  # offical module kabatti automatic git nimdi tisukumtumdhi, No need to give git::
  source = "terraform-aws-modules/alb/aws"  
  version = "9.16.0"
  internal = true     # <-- we need private load-balancer kabatti true
  name    = "${var.project}-${var.environment}-backend-alb" #roboshop-dev-backend-alb come on Console 
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  create_security_group = false     # <-- because we already created SG, kabatti default dhi false ani istam. 
  security_groups =[local.backend_alb_sg_id] # <-- [] 
  enable_deletion_protection = false 

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb" # name comes on the tags 
    }
  )
}

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn # arn--> amazon resources name, oka single output ID
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html" # <--
      message_body = "<h1>Hello, I am from Backend ALB Listener<h1>" # <--
      status_code  = "200"
    }
  }
}

# arn--> amazon resources name, oka single output ID, EC2->Load balancer -> roboshop-dev-backend-alb
# so listener velli load-balancer ki add avutumdhi.. 


# aws record terraform then take alias record example 
resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name    = "*.backend.${var.zone_name}"  # <-- *.backend
  type    = "A"

  alias {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id   # This is the zone id of ALB Not ours
    evaluate_target_health = true
  }
}