# 🔍  aws instance terraform, we are creating our own customised resourses

resource "aws_instance" "mongodb" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id]  # <-- [] for StringList
  subnet_id = local.database_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mongodb"
    }
  )
}

# first provider. 
# 1st security froup create chestam --> 2nd manam ssm parameter loki push cheyali --> 3rd rulues chuskovali manam inka bastion host vadakunda inka VPN nimdi connect avvali. I mean first mana lapi numdi VPN ki connect ayyi, VPN dhwara Mongodb ni connect avvali. ala ney Mongodb vachhesi ee VPN ni allow cheayli.. right. so sg group allow port No:22,27017. Okay up now security group(sg) create i poemdhi. 
# datasources, locals, variables, now null resources --> i mean terraform_data. yeppudu ite mongodb instance create avutumdo appudu terraform_data anedi trigger avutmdhi. 
# trigger aaye yemi cheyali. 
# generally ansible push based architure, and there is a one command called ansible-pull. so ee ansible server ni mongodb instance lo install cheste, anisble pull command dhawara, github nimdi role tisukoni tanani tanu configure chesukuntumdhi.. I mean mana role mention cheyali.  So appudu git clone ela anni cheyalisa pani ledu.. 
# terraform file provisioners use chesi file copy chestanu, 1st file copy cheyali ante connection tisukovali gha. so andhuke connection block
# okay done now I need to execute right. andhuke remote-exec

resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id # full instance kadu, only mongodb id anedi change ite ed itrigger avutmdhi, so .id 
  ]
  
   # Copies the myapp.conf file to /etc/myapp.conf
   # 🔍 terraform file provisioners
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"     # <-- name of user
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip    # < -- private ip & not self its aws_instance.mongodb
  }

    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb"
    ]
  }

}