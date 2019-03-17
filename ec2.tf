resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}

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

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.provisioner.rendered}"

  # Provisioning
  connection {
    agent       = false
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get install -yqq python3.6",
    ]
  }
}
