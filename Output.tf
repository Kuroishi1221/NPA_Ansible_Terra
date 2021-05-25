
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