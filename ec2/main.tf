resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "instance" {
  count                  = 1
  instance_type          = "${var.instance_type}"
  ami                    = "${var.aws_ami}"
  key_name               = "${aws_key_pair.auth.key_name}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id              = "${var.subnet_id}"

  root_block_device {
    volume_size = "${var.disk_size}"
  }

  lifecycle {
    create_before_destroy = true
  }

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
      "sudo apt-get install -yqq python",
    ]
  }
}
