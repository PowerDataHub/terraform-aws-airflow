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

variable "cluster_name" {
  description = "The name of the Airflow cluster (e.g. airflow-prod). This variable is used to namespace all resources created by this module."
}

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
  default = ""
}

#######
# EC2 #
#######

variable "webserver_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Webserver"
}

variable "scheduler_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Scheduler"
}

variable "disk_size" {
  default = 15
}

variable "ami" {
  type        = "string"
  default     = "ami-0a313d6098716f372"
  description = "Ubuntu 18.04 AMI code for the Airflow servers"
}

variable "spot_price" {
  description = "The maximum hourly price to pay for EC2 Spot Instances."
  default     = ""
}

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "standard"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 50
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each EC2 Instance in the cluster."
  default     = false
}
