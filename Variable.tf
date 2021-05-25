##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {
    default = "AKIA6KDTSZIXYUBPJ3SX"
}
variable "aws_secret_key" {
    default = "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"
}
variable "private_key_path" {
    default = "labsuser.pem"
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