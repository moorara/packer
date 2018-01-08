provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_key_pair" "packer-test" {
  key_name = "packer-test"
  public_key = "${file("packer-test.pub")}"
}

resource "aws_instance" "packer-test" {
  ami = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${aws_key_pair.packer-test.key_name}"
  tags {
    Name = "packer-test"
  }
}

output "aws_instance_id" {
  value = "${aws_instance.packer-test.id}"
}

output "aws_instance_ip" {
  value = "${aws_instance.packer-test.public_ip}"
}
