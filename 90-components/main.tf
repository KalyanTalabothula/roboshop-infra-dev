module "component" {
    for_each = var.components
    source = "../../terraform-aws-roboshop" # taking catalogue as module now 
    component = each.key
    rule_priority = each.value.rule_priority
}
