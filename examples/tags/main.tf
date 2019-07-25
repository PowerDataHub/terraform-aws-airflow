provider "aws" {
  region = "us-east-1"
}

#################################
# Data sources to get VPC details
#################################
data "aws_vpc" "default" {
  default = true
}

module "airflow_cluster" {
  source            = "../../"
  cluster_name      = "airflow-example-tags"
  s3_bucket_name    = "airflow-example-tags-logs"
  db_password       = "123456789A*"                                  # Just for example purposes, for real projects you may want to create a terraform.tfvars file
  fernet_key        = "HeY9Aivs7vADx5oy7SBKHfRJdj3fhpD_6IX2LnlDN74=" # Just for example purposes, for real projects you may want to create a terraform.tfvars file
  key_name          = "airflow-example-tags-key"
  load_example_dags = false
  tags = {
    Role = "airflow-infrastructure"
    Team = "AI Labs"
  }
}
