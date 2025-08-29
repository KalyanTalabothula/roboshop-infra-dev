# 🔍  aws acm terraform
resource "aws_acm_certificate" "kalyanu" {    # <--
  domain_name       = "*.kalyanu.site"
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

# next we need validation we need DNS not Email. Now it create records 
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