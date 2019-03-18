# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

###########
# Globals #
###########

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

variable "vpc_id" {
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  default     = ""
}

######
# S3 #
######

variable "s3_bucket_name" {
  default = "airflow-logs"
}

#######
# EC2 #
#######

variable "ec2_webserver_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Webserver"
}

variable "ec2_webserver_associate_public_ip_address" {
  default     = true
  description = "Should associate a public IP address to Webserver instance?"
}

variable "ec2_scheduler_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Scheduler"
}

variable "ec2_disk_size" {
  default = 15
}

variable "ec2_ami" {
  type        = "string"
  default     = "ami-0a313d6098716f372"
  description = "Ubuntu 18.04 AMI code for the Airflow servers"
}

variable "spot_price" {
  description = "The maximum hourly price to pay for EC2 Spot Instances."
  default     = ""
}
