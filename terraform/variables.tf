variable "aws_region" {
  description = "Region for the VPC"
  default = "eu-central-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  default = "XXXX"
}

variable "public_subnet_id" {
  description = "ID the Public Subnet"
  default = "XXXXX"
}

variable "ami" {
  description = "AMI for Windows SQL"
  default = "XXXXXX"
}

