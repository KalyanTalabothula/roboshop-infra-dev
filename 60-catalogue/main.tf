# 🔍 aws target group terraform

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"   #roboshop-dev-catalogue
  port     = 8080  # catalogue port no 8080 ni open chestunamdhi
  protocol = "HTTP"  # Load-balancer catalogue ni hit chesetappudu HTTP pina hit chestumdhi 
  vpc_id   = local.vpc_id
  deregistration_delay = 120  # just like notice period

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

# 🔍 catalogue instance ni create chestunna
resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]  
  subnet_id = local.private_subnet_id
  #iam_instance_profile = "EC2RoleToFetchSSMParameters"  # <-- role name
 
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id  # aws instance anedi create inappudu automatic gha edi trigger avutumdhi..
  ]
  
  provisioner "file" {
    source      = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"     
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip    
  }

    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }
}

# 🔍 aws_ec2_instance_state 
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"   # we have 2-options stopped & running only, NO DELETE option. 
  depends_on = [ terraform_data.catalogue ]
}

# 🔍 aws ami from instance terraform
resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id 
  depends_on = [ aws_ec2_instance_state.catalogue ]  # instance mottam stop ina tarawata, nenu AMI tisukovali. 

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

# 🔍 aws command line to terminate ec2
resource "terraform_data" "catalogue_delete" {   # <-- for delete ec2 instance
  triggers_replace = [
    aws_instance.catalogue.id  
  ]

  # make sure you have aws configure in your laptop 
    provisioner "local-exec" {  # <-- local-exec
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }

  depends_on = [ aws_ami_from_instance.catalogue ] # aws AMI create ina taruwata gha 
}

# 🔍 aws launch template terraform 
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"  # This name will display in console
  image_id = aws_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate" # ASG traffic tagginappudu STOP cheyatam kadu, terminate cheyali
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  update_default_version = true # Whenever u give terraform apply command --> New version will become default
  
  # EC2/Instance tags created by ASG
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

  # This tag is for volume created by ASG
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

  # Launch template tags 
    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )

}

# 👉 So in your code: That’s why you mentioned { tag_specifications } only for instance and volume – because those are the ones that need tagging at creation time. The launch template itself is tagged separately using { tags }.

# 🔍 aws autoscaling group terraform 
resource "aws_autoscaling_group" "catalogue" {
    name                 = "${var.project}-${var.environment}-catalogue"
  desired_capacity   = 1
  max_size           = 10     # you wish
  min_size           = 1    # minimum 1 ite yeppudu run avutu undali, traffic unna lekapoeena
  target_group_arns = [aws_lb_target_group.catalogue.arn] # its list []
  vpc_zone_identifier = local.private_subnet_ids # both private-subnets we are giving 
  health_check_grace_period = 90 # Launch chesina instance oka 90sec time istumdhi, then it will start health check
  health_check_type = "ELB" # ELB 0r ALB both are same names only. 
  # health check type 2- options unnae: EC2 ani este direct gha ASG monitor chestumdhi EC2 nii, In case ALB ani este, so EC2 ni direct monitor cheyadu. so aa ASG will directly respond I means health check report from somebody else dhani batti so ASG grace period ina tarawata, so it will gonna check EC2-instances, then it will refrashes. 
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
    content {
     key                 = tag.key
    value               = tag.value 
    propagate_at_launch = true
    }

  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"] 
  }

  timeouts {
    #update  = "15m" # create within 15 mins lopu. 
    delete = "15m" # max 15 mins lopu delete avvali.
  }
}

# 🔍 aws autoscaling policy terraform
resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling" # Target ni track chestu scale cheyatam
  #cooldown = 120  # yenta time taruwata dhini metrics collect chesukovachhu

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

# 🔍 aws listener rule terraform
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {  # yela vaste dhinni forward cheyali ante
    host_header {
      values = ["catalogue.backend-${var.environment}.${var.zone_name}"] #catalogue.backend-dev.daws84s.site
    }
  }
}


/* 🔄 Steps in Terraform Code (Catalogue Component)

1. Target Group create chesavu

Resource: aws_lb_target_group
ALB ki backend instances attach ayye group.
Health check path = /health.

2. Catalogue EC2 instance create chesavu

Resource: aws_instance
Security group + subnet ivvali.
Catalogue app run avvadaniki instance ready chestam.

3. EC2 lo script run cheyadaniki provisioner vaddam

Resource: terraform_data with file & remote-exec
catalogue.sh copy + execute.
App configure avvadaniki.

4. Instance stop cheyyadam

Resource: aws_ec2_instance_state
App configure ayyindi.
Instance stop cheyyali (AMI create cheyyadaniki).

5. AMI create cheyyadam from instance

Resource: aws_ami_from_instance
Instance stop aina tarvata AMI ready chestam.

6. Instance terminate cheyyadam

Resource: terraform_data with local-exec
AMI create ayyindi.
Unnecessary instance terminate chesavu.

7. Launch Template create chesavu

Resource: aws_launch_template
AMI id + Security group + tags define chesavu.
Ee template ni ASG use chestundi.

8. AutoScaling Group (ASG) create chesavu

Resource: aws_autoscaling_group
Desired = 1, min = 1, max = 10.
Launch template attach chesavu.
ALB target group connect chesavu.
Health check & rolling update configure chesavu.

9. AutoScaling Policy add chesavu

Resource: aws_autoscaling_policy
CPU utilization 75% target tracking.
Scale out/in avvadaniki.

10. Listener Rule create chesavu

Resource: aws_lb_listener_rule
ALB lo catalogue requests (domain match → catalogue.backend-dev...).
Correct target group ki forward chestundi.

📝 In Short Sequence:

Create Target Group
Create EC2 instance (app configure cheyadam)
Stop instance → take AMI → terminate instance
Create Launch Template with that AMI
Create AutoScaling Group attached to target group
Attach Scaling Policy (CPU based)
Create Listener Rule in ALB

👉 Easy ga gurthupettuko:
TG → EC2 → AMI → LT → ASG → Policy → Listener 🚀 */