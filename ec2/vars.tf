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

variable "ami" {
  type        = "string"
  default     = "ami-a042f4d8"
  description = "AMI code for the Airflow servers"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}
