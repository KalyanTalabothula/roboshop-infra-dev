module "vpc" {
    #source = "../terraform-aws-vpc"
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-vpc.git?ref=main"
    #source = "git::https://github.com/daws-84s/terraform-aws-vpc.git?ref=main"
    # project = "roboshop"
    # environment = "dev"
    # public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    project = var.project
    environment = var.environment
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs

    is_peering_required = true
}

# e module ni chustu unte function la kuda anukovachhu, module lopala manam inputs estunnam like DRY principle. 
# is_peering_required = true ani iste peering andhi create avutumdhi.. 
# source = "git::(https:key)?ref=main" manam platform engineer's create chesina valla module ni refer chesukuntunnam by refering their branch name. 

# output "vpc_id" {
#     value = module.vpc.vpc_id
# }  

# output "vpc_ids" {      # <--- list kada 
#     value = module.vpc.public_subnet_ids
# }

# value = module.vpc.(vpc_id), ee module devlop chesina vallu, valla output lo yedi echhi unte adi..
# value = module.vpc.(public_subnet_ids) same here too... ala ney manadi subnet ID's kabatti string list anedi suit avutumdhi. if you go and check in aws console ssm-parameters. ala ney TUPLE 0r LIST anna same. 
# then run the command in 00-vpc  $ terraform init -upgrade 