#provider "aws" {
#  region     = "us-east-1"
#  access_key = var.access_key
#  secret_key = var.secret_key
#}

resource "aws_vpc" "first_vpc" {
  cidr_block       = "10.0.0.0/16"
  #instance_tenancy = "default"

  tags = {
    Name = "hello-world-vpc"
  }
}

resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.first_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "hello-world-subnet"
  }
}