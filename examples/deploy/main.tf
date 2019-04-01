provider "aws" {
  region = "us-east-1"
}

#################################
# Data sources to get VPC details
#################################
data "aws_vpc" "default" {
  default = true
}

module "airflow-cluster" {
  source             = "../../"
  cluster_name       = "airflow-example"
  s3_bucket_name     = "airflow-example-logs"
  db_password        = "123456789A*"                                  # Just for example purposes, for real projects you may want to create a terraform.tfvars file
  fernet_key         = "HeY9Aivs7vADx5oy7SBKHfRJdj3fhpD_6IX2LnlDN74=" # Just for example purposes, for real projects you may want to create a terraform.tfvars file
  aws_key_name       = "airflow-example-key"
  vpc_id             = "${data.aws_vpc.default.id}"
  requirements_txt   = "./requirements.txt"
  load_example_dags  = false
  load_default_conns = false
  rbac               = true
  admin_username     = "admin"                                        # Only if rbac is true
  admin_password     = "123456789"                                    # Only if rbac is true
}
