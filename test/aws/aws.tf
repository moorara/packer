provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

resource "aws_key_pair" "packer-test" {
  key_name = "packer-test"
  public_key = file("packer-test.pub")
}

resource "aws_security_group" "packer-test" {
  name = "packer-test"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    to_port = -1
    from_port = -1
    protocol = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "packer-test"
  }
}

resource "aws_instance" "packer-test" {
  ami = var.aws_ami
  instance_type = var.aws_instance_type
  key_name = "${aws_key_pair.packer-test.key_name}"
  security_groups = [ "${aws_security_group.packer-test.name}" ]
  tags = {
    Name = "packer-test"
  }
}

output "aws_instance_id" {
  value = "${aws_instance.packer-test.id}"
}

output "aws_instance_ip" {
  value = "${aws_instance.packer-test.public_ip}"
}
