output "airflow_instance_public_dns" {
  value       = "${aws_instance.airflow_scheduler.public_dns}"
  description = "Public DNS for the Airflow instance"
}

output "airflow_instance_public_ip" {
  value       = "${aws_instance.airflow_scheduler.public_ip}"
  description = "Public IP address for the Airflow instance"
}
