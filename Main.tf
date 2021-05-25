

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

##################################################################################
# DATA
##################################################################################
data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


##################################################################################
# INSTANCES 
##################################################################################

resource "aws_instance" "NPA21_ansible" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet1.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install ansible2 -y",
        "ls -a",
        "ls -a"

    ]
  }

  tags ={
      Name = "ansibleNode"
  }

}

resource "aws_instance" "NPA21_web" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet1.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "ls -a"

    ]
  }

  tags ={
      Name = "web"
  }

}

resource "aws_instance" "NPA21_db1" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet1.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ec2-user"
        private_key = file(var.private_key_path)

    }


  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "ls -a"

    ]
  }

  tags ={
      Name = "db1"
  }
}

resource "aws_instance" "NPA21_ansible2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet2.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install ansible2 -y",
        "ls -a",
        "ls -a"

    ]
  }

  tags ={
      Name = "ansibleNode2"
  }

}

resource "aws_instance" "NPA21_web2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet2.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "ls -a"

    ]
  }

  tags ={
      Name = "web2"
  }

}

resource "aws_instance" "NPA21_db2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.NPA21_Public_Subnet2.id
  vpc_security_group_ids = [aws_security_group.NPA21_allow_ssh_web.id]
  key_name               = var.key_name

    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ec2-user"
        private_key = file(var.private_key_path)

    }


  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "ls -a"

    ]
  }

  tags ={
      Name = "db2"
  }
}

