
resource "aws_ssm_parameter" "frontend_sg_id" { # <-- give name properly
  name  = "/${var.project}/${var.environment}/frontend_sg_id" # <-- as per ssm-parameter standarded's
  type  = "String"
  value = module.frontend.sg_id  # <---
}

resource "aws_ssm_parameter" "bastion_sg_id" { # <-- give name properly
  name  = "/${var.project}/${var.environment}/bastion_sg_id" # <-- as per ssm-parameter standarded's
  type  = "String"
  value = module.bastion.sg_id  # <---
}