# 🔍 aws key terraform
# for windows nedd to use \\ double backslash, as well add pubkey. For Linu or MAC use / --> forward-slash. Now e file ni access chesi import chestumdhi AWS lopaliki. miru access cheyali annappudu mana dhaggara unte private key tho private sever ni acces cheyali. 

resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn"
  public_key = file("C:\\Users\\HP\\git-repo\\openvpn.pub") 
}

# 🔍 aws instance terraform, we are creating our own customised resourses

resource "aws_instance" "vpn" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.vpn_sg_id]  # <-- [] for StringList
  subnet_id = local.public_subnet_id
  #key_name = "daws-84" --> make sure this key exist in AWS
  key_name = aws_key_pair.openvpn.key_name 
  user_data = file("openvpn.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-vpn"
    }
  )
}

# 🔍 aws route53 terraform
resource "aws_route53_record" "vpn" {
  zone_id = var.zone_id
  name    = "vpn-${var.environment}.${var.zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.lb.public_ip]
}