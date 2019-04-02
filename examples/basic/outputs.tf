output "webserver_admin_url" {
  description = "Public DNS for the Airflow Webserver instance"
  value       = "${module.airflow_cluster.webserver_admin_url}"
}

output "webserver_public_ip" {
  description = "Public IP address for the Airflow Webserver instance"
  value       = "${module.airflow_cluster.webserver_public_ip}"
}
