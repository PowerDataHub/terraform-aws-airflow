module "airflow_labels" {
  source    = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace = var.cluster_name
  stage     = var.cluster_stage
  name      = "airflow"
  delimiter = "-"
  tags      = var.tags
}

module "airflow_labels_scheduler" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = var.cluster_name
  stage      = var.cluster_stage
  name       = "airflow"
  attributes = ["scheduler"]
  delimiter  = "-"
  tags       = var.tags
}

module "airflow_labels_webserver" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = var.cluster_name
  stage      = var.cluster_stage
  name       = "airflow"
  attributes = ["webserver"]
  delimiter  = "-"
  tags       = var.tags
}

module "airflow_labels_worker" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  namespace  = var.cluster_name
  stage      = var.cluster_stage
  name       = "airflow"
  attributes = ["worker"]
  delimiter  = "-"
  tags       = var.tags
}

