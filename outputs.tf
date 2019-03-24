output "airflow_webserver_public_dns" {
  value       = "${aws_instance.airflow_webserver.public_dns}"
  description = "Public DNS for the Airflow Webserver instance"
}

output "airflow_webserver_public_ip" {
  value       = "${aws_instance.airflow_webserver.public_ip}"
  description = "Public IP address for the Airflow Webserver instance"
}

output "airflow_database_endpoint" {
  value       = "${aws_db_instance.airflow_database.endpoint}"
  description = "Endpoint to connect to RDS metadata DB"
}

output "airflow_database_username" {
  value       = "${aws_db_instance.airflow_database.username}"
  description = "Username to connect to RDS metadata DB"
}
