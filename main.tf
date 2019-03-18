# -------------------------------------------
# DEPLOY AN AIRFLOW CLUSTER IN AWS
# -------------------------------------------

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}

# -------------------------------------------
# CREATE A S3 BUCKET TO STORAGE AIRFLOW LOGS
# -------------------------------------------

resource "aws_s3_bucket" "airflow-logs" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"

  tags = {
    Name = "${var.s3_bucket_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

module "sg_airflow" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "airflow-sg"
  description         = "Security group for Airflow machines"
  vpc_id              = "${data.aws_vpc.default.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

  tags {
    Name = "airflow-sg"
    Type = "sg"
  }
}

resource "aws_instance" "airflow_scheduler" {
  count                  = 1
  instance_type          = "${var.ec2_scheduler_instance_type}"
  ami                    = "${var.ec2_ami}"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.all.ids, 0)}"

  associate_public_ip_address = "${var.ec2_webserver_associate_public_ip_address}"

  root_block_device {
    volume_size = "${var.ec2_disk_size}"
  }

  tags {
    Name = "airflow_scheduler"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin:$HOME/.local/bin",
      "sudo apt-get update",
      "sudo apt-get install -yqq python3.6",
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
