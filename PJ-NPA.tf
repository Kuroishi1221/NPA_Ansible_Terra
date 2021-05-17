##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}
variable "network_address_space" {
  default = "10.1.0.0/16"
}
variable "Public1_address_space" {
  default = "10.1.0.0/24"
}
variable "subnet2_address_space" {
    default = "10.1.1.0/24"
}

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
# RESOURCES
##################################################################################

resource "aws_vpc" "testVPC" {
    cidr_block = var.network_address_space
    enable_dns_hostnames = true

    tags ={
        Name = "testVPC"
    }
}

resource "aws_subnet" "Public1" {
    vpc_id = aws_vpc.testVPC.id
    cidr_block = var.Public1_address_space
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    tags ={
        Name = "Public1"
    }
}

resource "aws_subnet" "Public2" {
    vpc_id = aws_vpc.testVPC.id
    cidr_block = var.subnet2_address_space
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags ={
        Name = "Public2"
    }
}

resource "aws_internet_gateway" "testIgw" {
    vpc_id = aws_vpc.testVPC.id

    tags ={
        Name = "testIgw"
    }
}

resource "aws_route_table" "publicRoute" {
    vpc_id = aws_vpc.testVPC.id
        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.testIgw.id
        }
    tags ={
        Name = "publicRoute"
    }
}

resource "aws_route_table_association" "rt-pubsub1" {
  subnet_id = aws_subnet.Public1.id
  route_table_id = aws_route_table.publicRoute.id
}

resource "aws_route_table_association" "rt-pubsub2" {
  subnet_id = aws_subnet.Public2.id
  route_table_id = aws_route_table.publicRoute.id
}

resource "aws_security_group" "elb-sg" {
    name = "elb-sg"
    vpc_id = aws_vpc.testVPC.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_ssh_web" {
  name        = "Project-NPA"
  description = "Allow ssh and web access"
  vpc_id      = aws_vpc.testVPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_address_space]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "webLB" {
    name = "web-elb"
    load_balancer_type = "application"
    internal = false
    subnets = [aws_subnet.Public1.id, aws_subnet.Public2.id]
    security_groups = [aws_security_group.elb-sg.id]
}

resource "aws_lb_target_group" "tgp" {
  name = "tf-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.testVPC.id

  depends_on = [
    aws_lb.webLB
  ]
}

resource "aws_lb_listener" "lbListener" {
  load_balancer_arn = aws_lb.webLB.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tgp.arn
    
  }
}
resource "aws_lb_target_group_attachment" "tgattach" {
  target_group_arn = aws_lb_target_group.tgp.arn
  target_id = aws_instance.web.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tgattach2" {
  target_group_arn = aws_lb_target_group.tgp.arn
  target_id = aws_instance.db1.id
  port = 80
}

##################################################################################
# INSTANCES 
##################################################################################

resource "aws_instance" "ansible" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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

resource "aws_instance" "db1" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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

resource "aws_instance" "ansible2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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

resource "aws_instance" "db2" {
  ami                    = data.aws_ami.aws-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
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


##################################################################################
# OUTPUT
##################################################################################

output "aws_lb_public_dns" {
  value = aws_lb.webLB.dns_name
}
output "aws_instance_private_ip_web" {
value = aws_instance.web.private_ip
}

output "aws_instance_public_ip_web" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.web.public_ip}"
}

output "aws_instance_private_ip_db1" {
value = aws_instance.db1.private_ip
}
output "aws_instance_public_ip_db1" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.db1.public_ip}"
}

output "aws_instance_public_ip_ansibleNode" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.web.public_ip}"
}



output "aws_instance_private_ip_web2" {
value = aws_instance.web2.private_ip
}

output "aws_instance_public_ip_web2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.web2.public_ip}"
}

output "aws_instance_private_ip_db2" {
value = aws_instance.db2.private_ip
}
output "aws_instance_public_ip_db2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.db2.public_ip}"
}

output "aws_instance_public_ip_ansibleNode2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.web2.public_ip}"
}