provider "aws" {
  region = "eu-central-1"

}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id


resource "aws_instance" "stormerify" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.stormerify.id]
  user_data = "${ file("userdata.sh")}"
  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Pavel Pogulailo"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "stormerify" {
  name        = "WebServer Security Group"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443","22"]
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
    Name  = "Web Server SecurityGroup"
    Owner = "Denis Astahov"
  }
}
resource "aws_route53_zone" "stormerify" {
  name = "stormerify.com"
}
resource "aws_route53_record" "stormerify" {
  allow_overwrite = true
  name            = "stormerify.com"
  ttl             = 300
  type            = "A"
  zone_id         = aws_route53_zone.stormerify.zone_id

  records = [aws_instance.stormerify.public_ip]
}
resource "aws_route53_record" "my_webserver2" {
  allow_overwrite = true
  name            = "www.stormerify.com"
  ttl             = 300
  type            = "A"
  zone_id         = aws_route53_zone.stormerify.zone_id

  records = [aws_instance.stormerify.public_ip]
}