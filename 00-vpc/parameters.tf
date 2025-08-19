# 🔍 aws ssm parameter store terraform

resource "aws_ssm_parameter" "vpc_id" { # <-- give name properly
  name  = "/${var.project}/${var.environment}/vpc_id" # <-- as per ssm-parameter standarded's
  type  = "String"
  value = module.vpc.vpc_id  # <---
}