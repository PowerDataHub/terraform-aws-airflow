variable "airflow_webserver_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Webserver"
}

variable "airflow_scheduler_instance_type" {
  type        = "string"
  default     = "t3.micro"
  description = "Instance type for the Airflow Scheduler"
}

variable "disk_size" {
  default = 15
}

variable "ami" {
  type        = "string"
  default     = "ami-a042f4d8"
  description = "AMI code for the Airflow servers"
}
