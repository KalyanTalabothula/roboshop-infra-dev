# 🔍  aws acm terraform
resource "aws_acm_certificate" "kalyanu" {    # <--
  domain_name       = "dev.${var.zone_name}"
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# next we need validation we need DNS not Email. Now it create records. 
# certificates lo nimdi tisukoni adi records anedi create chesukuntumdhi.
resource "aws_route53_record" "kalyanu" {
  for_each = {
    for dvo in aws_acm_certificate.kalyanu.domain_validation_options : dvo.domain_name => {  # <--
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id         # <--
}

# certificate create chusukunna taruwata validation ane button click cheyali
#  🔍 aws acm certificate validation 
resource "aws_acm_certificate_validation" "kalyanu" {
  certificate_arn         = aws_acm_certificate.kalyanu.arn
  validation_record_fqdns = [for record in aws_route53_record.kalyanu : record.fqdn]
}
# ante ee certificate ki ekkada create chesina records ni validate chestumdhi.. 

# manam export cheyali gha certificate ni, export cheste manam dhanini use chesukovachhu. so export cheyali ante we need ARN-Amazon resource name

# certificate create avutumdhi--> Records create avutunnae --> tarawata validate jarugutumdhi..