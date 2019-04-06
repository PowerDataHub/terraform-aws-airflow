terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

# ---------------------------------------
# AIRFLOW CLUSTER RESOURCES
# ---------------------------------------

# ---------------------------------------
# LABELS
# ---------------------------------------

module "airflow_labels" {
  source    = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace = "${var.cluster_name}"
  stage     = "${var.cluster_stage}"
  name      = "airflow"
  delimiter = "-"
}

module "airflow_labels_scheduler" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${var.cluster_name}"
  stage      = "${var.cluster_stage}"
  name       = "airflow"
  attributes = ["scheduler"]
  delimiter  = "-"
}

module "airflow_labels_webserver" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${var.cluster_name}"
  stage      = "${var.cluster_stage}"
  name       = "airflow"
  attributes = ["webserver"]
  delimiter  = "-"
}

module "airflow_labels_worker" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=master"
  namespace  = "${var.cluster_name}"
  stage      = "${var.cluster_stage}"
  name       = "airflow"
  attributes = ["worker"]
  delimiter  = "-"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name != "" ? var.key_name : module.airflow_labels.id}"
  public_key = "${file(var.public_key_path)}"
}

# -------------------------------------------
# CREATE A S3 BUCKET TO STORAGE AIRFLOW LOGS
# -------------------------------------------

resource "aws_s3_bucket" "airflow_logs" {
  bucket        = "${module.airflow_labels.id}-logs"
  acl           = "private"
  force_destroy = true

  tags = "${module.airflow_labels.tags}"
}

# ---------------------------------------
# CREATE A SQS TOPIC
# ---------------------------------------

resource "aws_sqs_queue" "airflow_queue" {
  name                      = "${module.airflow_labels.id}-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = "${module.airflow_labels.tags}"
}

# ---------------------------------------
# Policies and profile
# ---------------------------------------

module "ami_instance_profile" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/instance"

  service_name = "${module.airflow_labels.namespace}"
  cluster_role = "${module.airflow_labels.stage}"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = "${module.ami_instance_profile.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_policy" {
  role       = "${module.ami_instance_profile.role_name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_sqs_queue_policy" "sqs_permission" {
  queue_url = "${aws_sqs_queue.airflow_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.airflow_queue.arn}"
    }
  ]
}
POLICY
}

# ----------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ----------------------------------------------------------------------------------------

module "sg_airflow" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "${module.airflow_labels.id}-sg"
  description         = "Security group for ${module.airflow_labels.id} machines"
  vpc_id              = "${data.aws_vpc.default.id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "${module.airflow_labels.id} webserver"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5555
      to_port     = 5555
      protocol    = "tcp"
      description = "${module.airflow_labels.id} flower"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]

  tags = "${module.airflow_labels.tags}"
}

#-------------------------------------------------------------------------
# EC2
#-------------------------------------------------------------------------
resource "aws_instance" "airflow_webserver" {
  count = 1

  instance_type          = "${var.scheduler_instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.selected.ids, 0)}"
  iam_instance_profile   = "${module.ami_instance_profile.instance_profile_name}"

  associate_public_ip_address = true

  volume_tags = "${module.airflow_labels_webserver.tags}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  provisioner "file" {
    content     = "${data.template_file.custom_env.rendered}"
    destination = "/tmp/custom_env"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.custom_requirements.rendered}"
    destination = "/tmp/requirements.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_environment.rendered}"
    destination = "/tmp/airflow_environment"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_service.rendered}"
    destination = "/tmp/airflow.service"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo AIRFLOW_ROLE=WEBSERVER | sudo tee -a /etc/environment",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  user_data = "${data.template_file.provisioner.rendered}"
  tags      = "${module.airflow_labels_webserver.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "airflow_scheduler" {
  count = 1

  instance_type          = "${var.scheduler_instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.selected.ids, 0)}"
  iam_instance_profile   = "${module.ami_instance_profile.instance_profile_name}"

  associate_public_ip_address = true

  volume_tags = "${module.airflow_labels_webserver.tags}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  provisioner "file" {
    content     = "${data.template_file.custom_env.rendered}"
    destination = "/tmp/custom_env"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.custom_requirements.rendered}"
    destination = "/tmp/requirements.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_environment.rendered}"
    destination = "/tmp/airflow_environment"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_service.rendered}"
    destination = "/tmp/airflow.service"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo AIRFLOW_ROLE=SCHEDULER | sudo tee -a /etc/environment",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  user_data = "${data.template_file.provisioner.rendered}"
  tags      = "${module.airflow_labels_scheduler.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "airflow_worker" {
  count = "${var.worker_instance_count}"

  instance_type          = "${var.worker_instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${module.sg_airflow.this_security_group_id}"]
  subnet_id              = "${element(data.aws_subnet_ids.selected.ids, 0)}"
  iam_instance_profile   = "${module.ami_instance_profile.instance_profile_name}"

  associate_public_ip_address = true

  volume_tags = "${module.airflow_labels_webserver.tags}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  provisioner "file" {
    content     = "${data.template_file.custom_env.rendered}"
    destination = "/tmp/custom_env"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.custom_requirements.rendered}"
    destination = "/tmp/requirements.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_environment.rendered}"
    destination = "/tmp/airflow_environment"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_service.rendered}"
    destination = "/tmp/airflow.service"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo AIRFLOW_ROLE=WORKER | sudo tee -a /etc/environment",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  user_data = "${data.template_file.provisioner.rendered}"
  tags      = "${module.airflow_labels_worker.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

#-----------
# Database
#-----------

# -------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF RDS
# -------------------------------------------------------------------------

module "sg_database" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${module.airflow_labels.id}-database-sg"
  description = "Security group for ${module.airflow_labels.id} database"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  number_of_computed_ingress_with_source_security_group_id = 1

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = "${module.sg_airflow.this_security_group_id}"
      description              = "Allow ${module.airflow_labels.id} machines"
    },
  ]

  tags = "${module.airflow_labels.tags}"
}

resource "aws_db_instance" "airflow_database" {
  identifier              = "${module.airflow_labels.id}-db"
  allocated_storage       = "${var.db_allocated_storage}"
  engine                  = "postgres"
  engine_version          = "11.1"
  instance_class          = "${var.db_instance_type}"
  name                    = "${var.db_dbname}"
  username                = "${var.db_username}"
  password                = "${var.db_password}"
  storage_type            = "gp2"
  backup_retention_period = 14
  multi_az                = false
  publicly_accessible     = false
  apply_immediately       = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = ["${module.sg_database.this_security_group_id}"]
  port                    = "5432"
}
