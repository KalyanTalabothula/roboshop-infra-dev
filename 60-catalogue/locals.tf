
locals {
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    ami_id = data.aws_ami.joindevops.id

        common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
}