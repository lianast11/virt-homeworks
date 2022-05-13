provider "aws" {
   region = "us-west-2"
 }
 
 terraform {
   backend "s3" {
     bucket = "test-bucket-stage"
     key = "base/test1/terraform_aws.tfstate"
     region = "us-west-2"
     dynamodb_table = "test-db"
     encrypt = true
   }
 }
 
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals { 
  web_instance_type_map = {
    stage = "t3.micro"
    prod = "t3.large" 
  }
}

locals { 
  web_instance_count_map = {
    stage = 1
    prod = 2 
  }
}
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  count = local.web_instance_count_map[terraform.workspace]
lifecycle { 
    create_before_destroy = true 
  }
}

locals {
  instance_ids = toset([
    "instance-abcdef",
    "instance-012345",
  ])
}

resource "aws_instance" "server" {
  for_each = local.instance_ids

  ami           = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  tags = {
    Name = "Server ${each.key}"
  }
}
