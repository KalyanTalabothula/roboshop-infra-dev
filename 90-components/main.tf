module "component" {
    for_each = var.components
    source = "git::https://github.com/KalyanTalabothula/terraform-aws-roboshop.git?ref=main" # taking catalogue as module now 
    component = each.key
    rule_priority = each.value.rule_priority
}
