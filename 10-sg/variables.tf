
variable "project" {   # we can give same name as roboshop or different name
    type = string
    default = "roboshop"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "frontend_sg_name" {
    default = "frontend"
}

variable "frontend_sg_description" {
    default = "created sg for frontend instance"
}

variable "bastion_sg_name" {
    default = "bastion"
}

variable "bastion_sg_description" {
    default = "created sg for bastion instance"
}