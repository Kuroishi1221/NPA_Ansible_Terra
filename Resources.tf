##################################################################################
# RESOURCES
##################################################################################

resource "aws_vpc" "NPA21-VPC" {
    cidr_block = var.network_address_space
    enable_dns_hostnames = true

    tags ={
        Name = "NPA21-VPC"
    }
}

resource "aws_subnet" "NPA21_Public_Subnet1" {
    vpc_id = aws_vpc.NPA21-VPC.id
    cidr_block = var.Public1_address_space
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    tags ={
        Name = "NPA21_Public_Subnet1"
    }
}

resource "aws_subnet""NPA21_Public_Subnet2" {
    vpc_id = aws_vpc.NPA21-VPC.id
    cidr_block = var.subnet2_address_space
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags ={
        Name = "NPA21_Public_Subnet2"
    }
}

resource "aws_internet_gateway" "NPA21_IGW" {
    vpc_id = aws_vpc.NPA21-VPC.id

    tags ={
        Name = "NPA21_IGW"
    }
}

resource "aws_route_table" "NPA21_publicRoute" {
    vpc_id = aws_vpc.NPA21-VPC.id
        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.NPA21_IGW.id
        }
    tags ={
        Name = "NPA21_publicRoute"
    }
}

resource "aws_route_table_association" "NPA21_rt-pubsub1" {
  subnet_id = aws_subnet.NPA21_Public_Subnet1.id
  route_table_id = aws_route_table.NPA21_publicRoute.id
}

resource "aws_route_table_association" "NPA21_rt-pubsub2" {
  subnet_id = aws_subnet.NPA21_Public_Subnet2.id
  route_table_id = aws_route_table.NPA21_publicRoute.id
}

resource "aws_security_group" "NPA21_elb-sg" {
    name = "NPA21_elb-sg"
    vpc_id = aws_vpc.NPA21-VPC.id

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

resource "aws_security_group" "NPA21_allow_ssh_web" {
  name        = "NPA21_allow_ssh_web"
  description = "Allow ssh and web access"
  vpc_id      = aws_vpc.NPA21-VPC.id

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

resource "aws_lb" "NPA21_webLB" {
    name = "webLB"
    load_balancer_type = "application"
    internal = false
    subnets = [aws_subnet.NPA21_Public_Subnet1.id, aws_subnet.NPA21_Public_Subnet2.id]
    security_groups = [aws_security_group.NPA21_elb-sg.id]
}

resource "aws_lb_target_group" "NPA21_tgp" {
  name = "tf-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.NPA21-VPC.id

  depends_on = [
    aws_lb.NPA21_webLB
  ]
}

resource "aws_lb_listener" "NPA21_lbListener" {
  load_balancer_arn = aws_lb.NPA21_webLB.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.NPA21_tgp.arn
    
  }
}
resource "aws_lb_target_group_attachment" "NPA21_tgattach" {
  target_group_arn = aws_lb_target_group.NPA21_tgp.arn
  target_id = aws_instance.NPA21_web.id
  port = 80
}

resource "aws_lb_target_group_attachment" "NPA21_tgattach2" {
  target_group_arn = aws_lb_target_group.NPA21_tgp.arn
  target_id = aws_instance.NPA21_db1.id
  port = 80
}
