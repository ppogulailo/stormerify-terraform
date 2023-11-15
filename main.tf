provider "aws" {
  region = "eu-central-1"

}

resource "aws_default_vpc" "default" {}
# This need to be added since AWS Provider v4.29+ to get VPC id


resource "aws_instance" "stormerify" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = "${ file("userdata.sh")}"
  tags                   = {
    Name  = "Stormerify"
    Owner = "Pavel Pogulailo"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "security_group" {
  name        = "Security Group"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Stormerify"
    Owner = "PavelPogulailo"
  }
}
# request public certificates from the amazon certificate manager.
resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = "stormerify.com"
  subject_alternative_names = ["*.stormerify.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "route53_zone" {
  name = "stormerify.com"
}
resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.route53_zone.zone_id

}

# validate acm certificates
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}