output "webserver_admin_url" {
  description = "Public DNS for the Airflow Webserver instance"
  value       = "${module.airflow_cluster.webserver_admin_url}"
}

output "webserver_public_ip" {
  description = "Public IP address for the Airflow Webserver instance"
  value       = "${module.airflow_cluster.webserver_public_ip}"
}

output "this_cluster_security_group_id" {
  description = "The ID of the security group"
  value       = "${module.airflow_cluster.this_cluster_security_group_id}"
}

output "this_database_security_group_id" {
  description = "The ID of the security group"
  value       = "${module.airflow_cluster.this_database_security_group_id}"
}

output "database_endpoint" {
  description = "Endpoint to connect to RDS metadata DB"
  value       = "${module.airflow_cluster.database_endpoint}"
}

output "database_username" {
  description = "Username to connect to RDS metadata DB"
  value       = "${module.airflow_cluster.database_username}"
}
