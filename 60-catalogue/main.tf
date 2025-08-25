# 🔍 aws target group terraform

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"   #roboshop-dev-catalogue
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold = 2 
    interval = 5
    matcher = "200-299"
    path = "/health"
    port = 8080
    #protocol = "HTTP" # default gha untumdhi, no need to mention here. 
    timeout = 2
    unhealthy_threshold = 3
  }
}

# prati backend component lo /health ani okati undi dhanipina hit cheste health or unhealthy ani telustumdhi

resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.mysql_sg_id]  
  subnet_id = local.database_subnet_id
  iam_instance_profile = "EC2RoleToFetchSSMParameters"  # <-- role name
 
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mysql"
    }
  )
}