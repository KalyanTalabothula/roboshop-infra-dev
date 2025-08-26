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
