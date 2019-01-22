provider "aws" {
 region = "us-east-1"
}

variable "conjur_ami_id" {
  type    = "string"
}

variable "route53_zone_name" {
  type    = "string"
}

resource "tls_private_key" "conjur_pcf_access_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "conjur_pcf_vm_key"
  public_key = "${tls_private_key.conjur_pcf_access_key.public_key_openssh}"
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow Conjur traffic"

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH remote access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "conjur" {
  ami           = "${var.conjur_ami_id}"
  instance_type = "t2.medium"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  security_groups = [
        "${aws_security_group.allow_http_ssh.name}",
    ]

  tags = {
    Name = "PCF Integration Testing Conjur"
  }
}

data "aws_route53_zone" "primary" {
  name = "${var.route53_zone_name}"
}

resource "aws_route53_record" "conjur-pcf" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "conjur-pcf"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.conjur.public_dns}"]
}

output "address" {
  value = "${aws_instance.conjur.public_dns}"
}

output "ssh_key" {
  sensitive = true
  value = "${tls_private_key.conjur_pcf_access_key.private_key_pem}"
}
