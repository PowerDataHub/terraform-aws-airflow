###########
# Globals #
###########

variable "ami" {
  description = "Default is `Ubuntu Server 18.04 LTS (HVM), SSD Volume Type.`"
  type        = string
  default     = "ami-0ac80df6eff0e70b5"
}

variable "cluster_name" {
  description = "The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module."
  type        = string
}

variable "cluster_stage" {
  description = "The stage of the Airflow cluster (e.g. prod)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "AWS KeyPair name."
  type        = string
  default     = null
}

variable "private_key" {
  description = "Enter the content of the SSH Private Key to run provisioner."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Enter the content of the SSH Public Key to run provisioner."
  type        = string
  default     = null
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  type        = string
  default     = null
}

variable "fernet_key" {
  description = "Key for encrypting data in the database - see Airflow docs."
  type        = string
}

variable "custom_requirements" {
  description = "Path to custom requirements.txt."
  type        = string
  default     = null
}

variable "custom_env" {
  description = "Path to custom airflow environments variables."
  type        = string
  default     = null
}

variable "load_example_dags" {
  description = "Load the example DAGs distributed with Airflow. Useful if deploying a stack for demonstrating a few topologies, operators and scheduling strategies."
  type        = bool
  default     = false
}

variable "load_default_conns" {
  description = "Load the default connections initialized by Airflow. Most consider these unnecessary, which is why the default is to not load them."
  type        = bool
  default     = false
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_with_cidr_blocks" {
  description = "List of computed ingress rules to create where 'cidr_blocks' is used"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = [
    {
      description = "Airflow webserver"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Airflow flower"
      from_port   = 5555
      to_port     = 5555
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

variable "tags" {
  description = "Additional tags used into terraform-terraform-labels module."
  type        = map(string)
  default     = {}
}

variable "rbac" {
  description = "Enable support for Role-Based Access Control (RBAC)."
  type        = string
  default     = false
}

variable "admin_name" {
  description = "Admin name. Only If RBAC is enabled, this user will be created in the first run only."
  type        = string
  default     = "John"
}

variable "admin_lastname" {
  description = "Admin lastname. Only If RBAC is enabled, this user will be created in the first run only."
  type        = string
  default     = "Doe"
}

variable "admin_email" {
  description = "Admin email. Only If RBAC is enabled, this user will be created in the first run only."
  type        = string
  default     = "admin@admin.com"
}

variable "admin_username" {
  description = "Admin username used to authenticate. Only If RBAC is enabled, this user will be created in the first run only."
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password. Only If RBAC is enabled."
  type        = string
  default     = false
}

######
# S3 #
######

variable "s3_bucket_name" {
  description = "S3 Bucket to save airflow logs."
  type        = string
  default     = ""
}

#######
# EC2 #
#######

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type        = map(string)
  default = {
    "1" = "us-east-1a"
    "2" = "us-east-1b"
    "3" = "us-east-1c"
    "4" = "us-east-1d"
  }
}

variable "instance_subnet_id" {
  description = "subnet id used for ec2 instances running airflow, if not defined, vpc's first element in subnetlist will be used"
  type        = string
  default     = ""
}

variable "webserver_instance_type" {
  description = "Instance type for the Airflow Webserver."
  type        = string
  default     = "t3.micro"
}

variable "webserver_port" {
  description = "The port Airflow webserver will be listening. Ports below 1024 can be opened only with root privileges and the airflow process does not run as such."
  type        = string
  default     = "8080"
}

variable "scheduler_instance_type" {
  description = "Instance type for the Airflow Scheduler."
  type        = string
  default     = "t3.micro"
}

variable "worker_instance_type" {
  description = "Instance type for the Celery Worker."
  type        = string
  default     = "t3.small"
}

variable "worker_instance_count" {
  description = "Number of worker instances to create."
  type        = string
  default     = 1
}

variable "spot_price" {
  description = "The maximum hourly price to pay for EC2 Spot Instances."
  default     = ""
}

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  type        = string
  default     = "gp2"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  type        = string
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
  description = "Instance type for PostgreSQL database"
  type        = string
  default     = "db.t2.micro"
}

variable "db_username" {
  description = "PostgreSQL username."
  type        = string
  default     = "airflow"
}

variable "db_dbname" {
  description = "PostgreSQL database name."
  type        = string
  default     = "airflow"
}

variable "db_password" {
  description = "PostgreSQL password."
  type        = string
}

variable "db_allocated_storage" {
  description = "Dabatase disk size."
  type        = string
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 0
}

variable "db_subnet_group_name" {
  description = "db subnet group, if assigned, db will create in that subnet, default create in default vpc"
  type        = string
  default     = ""
}

#------------------------------------------------------------
# Data sources
#------------------------------------------------------------

data "aws_vpc" "default" {
  default = var.vpc_id == "" ? true : false
  id      = var.vpc_id
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

data "template_file" "airflow_service" {
  template = file("${path.module}/files/airflow.service")
}

data "template_file" "custom_env" {
  template = file(
    coalesce(var.custom_env, "${path.module}/.env.custom.airflow"),
  )
}

data "template_file" "custom_requirements" {
  template = file(
    coalesce(var.custom_requirements, "${path.module}/requirements.txt"),
  )
}

data "template_file" "airflow_environment" {
  template = file("${path.module}/files/.env.airflow")

  vars = {
    AWS_REGION         = var.aws_region
    FERNET_KEY         = var.fernet_key
    LOAD_EXAMPLE_DAGS  = var.load_example_dags
    LOAD_DEFAULT_CONNS = var.load_default_conns
    RBAC               = var.rbac
    ADMIN_NAME         = var.admin_name
    ADMIN_LASTNAME     = var.admin_lastname
    ADMIN_EMAIL        = var.admin_email
    ADMIN_USERNAME     = var.admin_username
    ADMIN_PASSWORD     = var.admin_password
    DB_USERNAME        = var.db_username
    DB_PASSWORD        = var.db_password
    DB_ENDPOINT        = aws_db_instance.airflow_database.endpoint
    DB_DBNAME          = var.db_dbname
    S3_BUCKET          = aws_s3_bucket.airflow_logs.id
    # WEBSERVER_HOST     = "${aws_instance.airflow_webserver.public_dns}"
    WEBSERVER_PORT = var.webserver_port
    QUEUE_NAME     = "${module.airflow_labels.id}-queue"
  }
}

data "template_file" "provisioner" {
  template = file("${path.module}/files/cloud-init.sh")

  vars = {
    AWS_REGION         = var.aws_region
    FERNET_KEY         = var.fernet_key
    LOAD_EXAMPLE_DAGS  = var.load_example_dags
    LOAD_DEFAULT_CONNS = var.load_default_conns
    RBAC               = var.rbac
    ADMIN_NAME         = var.admin_name
    ADMIN_LASTNAME     = var.admin_lastname
    ADMIN_EMAIL        = var.admin_email
    ADMIN_USERNAME     = var.admin_username
    ADMIN_PASSWORD     = var.admin_password
    DB_USERNAME        = var.db_username
    DB_PASSWORD        = var.db_password
    DB_ENDPOINT        = aws_db_instance.airflow_database.endpoint
    DB_DBNAME          = var.db_dbname
    S3_BUCKET          = aws_s3_bucket.airflow_logs.id
    # WEBSERVER_HOST     = "${aws_instance.airflow_webserver.public_dns}"
    WEBSERVER_PORT = var.webserver_port
    QUEUE_NAME     = "${module.airflow_labels.id}-queue"
  }
}
