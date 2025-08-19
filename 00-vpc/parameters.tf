# 🔍 aws ssm parameter store terraform

resource "aws_ssm_parameter" "vpc_id" { # <-- give name properly
  name  = "/${var.project}/${var.environment}/vpc_id" # <-- as per ssm-parameter standarded's
  type  = "String"
  value = module.vpc.vpc_id  # <---
}

resource "aws_ssm_parameter" "public_subnet_ids" { # <-- give name properly because its subnet its always list so S
  name  = "/${var.project}/${var.environment}/public_subnet_ids" # <-- as per ssm-parameter standarded's
  type  = "StringList"    # as per console name S,L letters.
  value = join(",", module.vpc.public_subnet_ids) # <-- as per module team vallu yedi iste a name 
}

# value = join(",", module.vpc.public_subnet_ids) so edi list laga kakunda oka string laga store avutmdhi. by using join funtion. rest two subnets are same like as public

resource "aws_ssm_parameter" "private_subnet_ids" { 
  name  = "/${var.project}/${var.environment}/private_subnet_ids" 
  type  = "StringList"   
  value = join(",", module.vpc.private_subnet_ids) 
}

resource "aws_ssm_parameter" "database_subnet_ids" { 
  name  = "/${var.project}/${var.environment}/database_subnet_ids" 
  type  = "StringList"    
  value = join(",", module.vpc.database_subnet_ids) 
}