##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {
    default = ""
}
variable "aws_secret_key" {
    default = ""
}
variable "private_key_path" {
    default = ""
}
variable "key_name" {
    default = "vockey"
}
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