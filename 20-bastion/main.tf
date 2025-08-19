# 🔍  aws instance terraform, we are creating our own customised resourses

resource "aws_instance" "bastion" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]  # <-- [] for StringList
  subnet_id = local.public_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-bastion"
    }
  )
}

# subnet evvaka pote default VPC lo unde Default dhantlo create avutumdhi.. manaki kavasimdi roboshop kabatti manam kachhitam gha subnet anedhi evvali.. Aws instance lo subnet_id anedi untumdhi.. 
# miru provider evvaka poena work avutumdhi, appudu state local lo save avutmdhi