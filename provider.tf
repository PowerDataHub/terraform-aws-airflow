# Define AWS as our provider
provider "aws" {
  region  = "${var.aws_region}"
  version = ">= 1.7.1"
}
