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
