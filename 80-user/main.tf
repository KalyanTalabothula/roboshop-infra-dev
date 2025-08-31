module "user" {
    source = "../../terraform-aws-roboshop" # taking catalogue as module now 
    component = "user"
    rule_priority = 20 
}