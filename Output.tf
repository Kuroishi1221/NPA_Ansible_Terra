
##################################################################################
# OUTPUT
##################################################################################

output "aws_lb_public_dns" {
  value = aws_lb.NPA21_webLB.dns_name
}
output "aws_instance_private_ip_web" {
value = aws_instance.NPA21_web.private_ip
}

output "aws_instance_public_ip_web" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_web.public_ip}"
}

output "aws_instance_private_ip_db1" {
value = aws_instance.NPA21_db1.private_ip
}
output "aws_instance_public_ip_db1" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_db1.public_ip}"
}

output "aws_instance_public_ip_ansibleNode" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_web.public_ip}"
}



output "aws_instance_private_ip_web2" {
value = aws_instance.NPA21_web2.private_ip
}

output "aws_instance_public_ip_web2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_web2.public_ip}"
}

output "aws_instance_private_ip_db2" {
value = aws_instance.NPA21_db2.private_ip
}
output "aws_instance_public_ip_db2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_db2.public_ip}"
}

output "aws_instance_public_ip_ansibleNode2" {
value = "ssh -i vockey.pem ec2-user@${aws_instance.NPA21_web2.public_ip}"
}