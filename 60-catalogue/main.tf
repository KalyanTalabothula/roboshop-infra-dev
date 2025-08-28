# 🔍 aws target group terraform

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"   #roboshop-dev-catalogue
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 120

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
resource "aws_autoscaling_group" "example" {
    name                 = "${var.project}-${var.environment}-catalogue"
  desired_capacity   = 1
  max_size           = 10     # you wish
  min_size           = 1    # minimum 1 ite yeppudu run avutu undali, traffic unna lekapoeena
  target_group_arns = [aws_lb_target_group.catalogue.arn] # its list []
  vpc_zone_identifier = local.private_subnet_ids # both private-subnets we are giving 

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }

  tag {
    key                 = "Key"
    value               = "Value"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}