output "this_cluster_security_group_id" {
  description = "The ID of the security group"
  value       = module.sg_airflow.this_security_group_id
}

output "this_database_security_group_id" {
  description = "The ID of the security group"
  value       = module.sg_database.this_security_group_id
}

output "webserver_admin_url" {
  description = "Url for the Airflow Webserver Admin"
  value       = "http://${aws_instance.airflow_webserver[0].public_dns}:${var.webserver_port}"
}

output "webserver_public_ip" {
  description = "Public IP address for the Airflow Webserver instance"
  value       = [aws_instance.airflow_webserver.*.public_ip]
}

output "database_endpoint" {
  description = "Endpoint to connect to RDS metadata DB"
  value       = aws_db_instance.airflow_database.endpoint
}

output "database_username" {
  description = "Username to connect to RDS metadata DB"
  value       = aws_db_instance.airflow_database.username
}

