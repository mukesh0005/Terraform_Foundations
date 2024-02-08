provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}



resource "aws_instance" "first_server" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  iam_instance_profile  = aws_iam_role.veera_role.name
  
  tags = {
    Name = "HelloWorld1"
  }
}