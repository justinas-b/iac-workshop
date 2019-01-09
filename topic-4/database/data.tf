provider "aws" {
  region = "${var.region}"
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "john-snow-state-437278685207"
    key    = "workshop/vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}


locals {
  generic_tag  = "${var.owner}-${terraform.workspace}"
  subnet_group_name = "${local.generic_tag}-subnet-group"
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  identifier             = "${local.generic_tag}"
  name                   = "${var.db_name}"
  username               = "${var.db_user}"
  password               = "${var.db_password}"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.subnet_group_name}"
  subnet_ids = ["${data.terraform_remote_state.vpc.private_db_subnets}"]
}

//-----------------------------------------
// RDS Security Group and rules
//-----------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.owner}-rds-${terraform.workspace}"
  description = "Allow traffic to DB"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "db_access" {
  description              = "Allow MySQL access from app servers"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.rds.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.asg_sg_id}"
}