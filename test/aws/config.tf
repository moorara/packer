variable "aws_access_key" {
  type = "string"
}

variable "aws_secret_key" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "aws_ami" {
  type = "string"
}

variable "aws_instance_type" {
  type = "string"
  default = "t2.micro"
}
