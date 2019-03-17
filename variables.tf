variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_key_name" {
  description = "SSH KeyPair"
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  default     = "~/.ssh/id_rsa"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_rsa.pub"
}
