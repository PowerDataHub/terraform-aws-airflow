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

variable "fernet_key" {
  type        = "string"
  description = "Key for encrypting data in the database - see Airflow docs"
}

variable "requirements_txt" {
  type        = "string"
  description = "Custom requirements.txt"
  default     = ""
}

variable "load_example_dags" {
  type        = "string"
  description = "Load the example DAGs distributed with Airflow. Useful if deploying a stack for demonstrating a few topologies, operators and scheduling strategies."
  default     = false
}

variable "load_default_conns" {
  type        = "string"
  description = "Load the default connections initialized by Airflow. Most consider these unnecessary, which is why the default is to not load them."
  default     = false
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
  default     = 35
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
# Data sources
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

data "template_file" "requirements_txt" {
  template = "${file("${var.requirements_txt}")}"
}

data "template_file" "airflow-service" {
  template = "${file("${path.module}/files/airflow.service")}"
}

data "template_file" "airflow-environment" {
  template = "${file("${path.module}/files/airflow.environment")}"

  vars = {
    AWS_REGION         = "${var.aws_region}"
    FERNET_KEY         = "${var.fernet_key}"
    LOAD_EXAMPLE_DAGS  = "${var.load_example_dags}"
    LOAD_DEFAULT_CONNS = false
    DB_USERNAME        = "${var.db_username}"
    DB_PASSWORD        = "${var.db_password}"
    DB_ENDPOINT        = "${aws_db_instance.airflow-database.endpoint}"
    DB_DBNAME          = "${var.db_dbname}"
    S3_BUCKET          = "${aws_s3_bucket.airflow-logs.id}"

    # WEBSERVER_HOST     = "${aws_instance.airflow_webserver.public_dns}"
    WEBSERVER_PORT = "8080"
    QUEUE_NAME     = "${module.airflow_labels.id}-queue"
  }
}
