# Replace the public_key below with your own public key
resource "aws_key_pair" "deployer" {
  key_name   = "lernard-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4N66sMjP2Q2OuJi1sVpKjiJJojZWF/iqAIF32rEorEdfVN4Eroh7uTxW17tkpfmufB2DQTBRNjLueyyPrlW8/+DYDQpBUpOsMELsTB40mpnK0BXPN70sjUqVdWgu50NTpZJhilN9MX1gkSLHFUi/u+UXirRReYBBeEjReD0g9gLMTDg/bGtHtcdLFwmSbGvuMcws8P9xEVkA4IEHFhLPKfYyFICzzL/JJKWDD4CbvHgDjV0zsEb4Pq2bip7V9ppS2CpIcLWiCQd56ffzqIBoLzQlef9SdSCX1xIcF4ODb+qt+T2SKv6+Vj2bRAS6fhLtIm+2mcnFysJuj4c/EGqEb lernard@lernard-VirtualBox"
}

# Connects us into AWS in the appropriate region. You must have set up your credentials with awscli for this to work
provider "aws" {
    region = "us-east-1"
}

# Spins us up a server, with the operating system defined in the "ubuntu-18.04" data source below. Notice the "key_name" matches the one defined above.
resource "aws_instance" "webserver" {
    ami = data.aws_ami.ubuntu-18_04.id
    instance_type   = "t2.micro"
    key_name        = "lernard-key"
    vpc_security_group_ids = [aws_security_group.web.id]

    tags = {
        Name = "lernard_webserver"
    }
}

# Defines the allowed ports for our security group the server is attached to
resource "aws_security_group" "web" {
    name        = "lernard_web"
    description = "Allow all 80, 22"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        # Replace this with your own IP address
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "ip_address" {
    value = aws_instance.webserver.public_ip
}

# Gets us the most recent AMI image ID (operating system) that matches the search string below
data "aws_ami" "ubuntu-18_04" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

# Defines that we store our tfstate in lernard-backend s3 bucket. This is optional, delete if desired.
terraform {
    backend "s3" {
        bucket  = "lernard-backend"
        key     = "Ansible"
        region  = "us-east-1"
    }
}