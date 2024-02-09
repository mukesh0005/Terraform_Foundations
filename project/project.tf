provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#1. create a custom vpc

resource "aws_vpc" "tf_project_vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "tf-project-vpc"
  }
}

#2. create a internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tf_project_vpc.id

  tags = {
    Name = "tf-project-ig"
  }
}

#3. custom route table

resource "aws_route_table" "tf_project_route_table" {
  vpc_id = aws_vpc.tf_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "tf-project-route-table"
  }
}

#4. create subnet

resource "aws_subnet" "tf_project_subnet" {
  vpc_id     = aws_vpc.tf_project_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-project-subnet"
  }
}

#5. Subnet association with route table.

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf_project_subnet.id
  route_table_id = aws_route_table.tf_project_route_table.id
}

#6. create a security group to allow 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "allow web inbound traffic"
  vpc_id      = aws_vpc.tf_project_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow web"
  }
}

#7. create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "project" {
  subnet_id       = aws_subnet.tf_project_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
#8. Create an elastic ip

resource "aws_eip" "elastic_ip" {
    network_interface = aws_network_interface.project.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [ aws_internet_gateway.gw ]
  
}

#9. create an server

resource "aws_instance" "project_server" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "prokey"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.project.id
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c "echo 'first project' > /var/www/html/index.html"
    EOF

  tags = {
    Name = "project"
  }
}

