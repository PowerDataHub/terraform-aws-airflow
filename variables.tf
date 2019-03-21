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
  type        = "string"
  description = "The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module."
}

variable "cluster_stage" {
  type        = "string"
  description = "The stage of the Airflow cluster (e.g. prod)."
  default     = "dev"
}

variable "aws_region" {
  type        = "string"
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_key_name" {
  type        = "string"
  description = "AWS KeyPair name"
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
  type        = "string"
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  default     = ""
}

######
# S3 #
######

variable "s3_bucket_name" {
  type    = "string"
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

variable "worker_instance_type" {
  type        = "string"
  default     = "t3.small"
  description = "Instance type for the Celery Worker"
}

variable "ami" {
  type        = "string"
  default     = "ami-0a313d6098716f372"
  description = "Default is: Ubuntu Server 18.04 LTS (HVM), SSD Volume Type."
}

variable "spot_price" {
  description = "The maximum hourly price to pay for EC2 Spot Instances."
  default     = ""
}

variable "root_volume_ebs_optimized" {
  type        = "string"
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "root_volume_type" {
  type        = "string"
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "standard"
}

variable "root_volume_size" {
  type        = "string"
  description = "The size, in GB, of the root EBS volume."
  default     = 30
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
}

############
# DATABASE #
############

variable "db_instance_type" {
  type        = "string"
  default     = "db.t2.micro"
  description = "Instance type for PostgreSQL database"
}

variable "db_username" {
  description = "PostgreSQL username."
  default     = "airflow"
}

variable "db_dbname" {
  description = "PostgreSQL database name."
  default     = "airflow"
}

variable "db_password" {
  description = "PostgreSQL password."
}

variable "db_allocated_storage" {
  type        = "string"
  description = "Dabatase disk size."
  default     = 20
}

#------------------------------------------------------------
# Data sources to get VPC, subnets and security group details
#------------------------------------------------------------

data "aws_vpc" "default" {
  default = "${var.vpc_id == "" ? true : false}"
  id      = "${var.vpc_id}"
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

data "template_file" "provisioner" {
  template = "${file("${path.module}/files/cloud-init.sh")}"
}
