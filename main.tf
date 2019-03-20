# -------------------------------------------
# DEPLOY AN AIRFLOW CLUSTER IN AWS
# -------------------------------------------

terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

module "airflow_labels" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${var.cluster_name}"
  stage      = "${var.cluster_stage}"
  name       = "airflow"
  attributes = ["public"]
  delimiter  = "-"
}

# -------------------------------------------
# CREATE A S3 BUCKET TO STORAGE AIRFLOW LOGS
# -------------------------------------------

resource "aws_s3_bucket" "airflow-logs" {
  bucket = "${var.cluster_name}-${var.s3_bucket_name}"
  acl    = "private"

  tags = "${module.airflow_labels.tags}"
}

# ----------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ----------------------------------------------------------------------------------------

module "sg_airflow" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "${var.cluster_name}-sg"
  description         = "Security group for ${var.cluster_name} machines"
  vpc_id              = "${data.aws_vpc.default.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = "${module.airflow_labels.tags}"
}

resource "aws_instance" "airflow_webserver" {
  count                  = 1
  instance_type          = "${var.scheduler_instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${var.aws_key_name}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.all.ids, 0)}"

  associate_public_ip_address = "${var.associate_public_ip_address}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  tags = "${module.airflow_labels.tags}"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin:$HOME/.local/bin",
      "sudo apt-get update",
      "sudo apt-get install -yqq python3",
    ]

    # Provisioning
    connection {
      agent       = false
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  user_data = "${data.template_file.provisioner.rendered}"
}

resource "aws_instance" "airflow_scheduler" {
  count                  = 1
  instance_type          = "${var.scheduler_instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${var.aws_key_name}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.all.ids, 0)}"

  associate_public_ip_address = "${var.associate_public_ip_address}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  tags = "${module.airflow_labels.tags}"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin:$HOME/.local/bin",
      "sudo apt-get update",
      "sudo apt-get install -yqq python3",
    ]

    # Provisioning
    connection {
      agent       = false
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  user_data = "${data.template_file.provisioner.rendered}"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################

data "aws_vpc" "default" {
  default = "${var.vpc_id == "" ? true : false}"
  id      = "${var.vpc_id}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

data "template_file" "provisioner" {
  template = "${file("${path.module}/files/cloud-init.sh")}"
}
