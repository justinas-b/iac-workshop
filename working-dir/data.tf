
locals {
  subnet_group_name = "${local.generic_tag}-subnet-group"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "${local.generic_tag}"
  name                 = "mydb"
  username             = "${var.db_user}"
  password             = "${var.db_password}"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.subnet_group_name}"
  subnet_ids = ["${aws_subnet.private.*.id}"]
}

