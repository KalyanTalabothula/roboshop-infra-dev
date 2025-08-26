variable "project" {   # we can give same name as roboshop or different name
    type = string
    default = "roboshop"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "zone_id" {
    type = string
    default = "Z00927541W472WAHJVTNL"
}

variable "zone_name" {
  type = string
  default = "kalyanu.xyz"
}