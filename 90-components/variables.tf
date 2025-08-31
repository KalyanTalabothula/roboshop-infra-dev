variable "components" {
    default = {
        catalogue = {
            rule_priority = 10
        }
        user = {
            rule_priority = 20
        }
        cart = {      # key 
            rule_priority = 30  # value
        }
        shipping = {
            rule_priority = 40
        }
        payment = {
            rule_priority = 50
        }
        frontend = {
            rule_priority = 10
        }
    }
}

# ela yendhuku rayakudadu ante andharu okkate ipotunnaru gha, user vallu cart vallu all