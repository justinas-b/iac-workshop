provider "aws" {
  region = "${var.region}"
}

locals {
  generic_tag  = "${var.owner}-${terraform.workspace}"
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "${var.state_bucket}"
    key    = "workshop/vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config {
    bucket = "${var.state_bucket}"
    key    = "workshop/data/terraform.tfstate"
    region = "${var.region}"
  }
}

//-----------------------------------------
// Application layer components
//-----------------------------------------
# Fetching and filtering amazon AMI
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    db_endpoint = "${data.terraform_remote_state.data.db_endpoint}"
    db_name     = "${var.db_name}"
    db_user     = "${var.db_user}"
    db_password = "${var.db_password}"
    alb_dns     = "${aws_lb.load_balancer.dns_name}"
    owner       = "${var.owner}"
  }
}

resource "aws_launch_configuration" "as_conf" {
  name            = "${var.owner}-lc-${terraform.workspace}"
  image_id        = "${data.aws_ami.ami.id}"
  instance_type   = "t2.micro"
  user_data       = "${data.template_file.init.rendered}"
  security_groups = ["${data.terraform_remote_state.vpc.asg_sg_id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.owner}-asg-${aws_launch_configuration.as_conf.name}"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 0
  max_size             = 4
  desired_capacity     = 2
  min_elb_capacity     = 2
  target_group_arns    = ["${aws_lb_target_group.alb_tg.arn}"]
  vpc_zone_identifier  = ["${data.terraform_remote_state.vpc.private_compute_subnets}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "${local.generic_tag}-asg-policy"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

//-----------------------------------------
// ALB
//-----------------------------------------
resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.owner}-lb-tg-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_lb" "load_balancer" {
  name                       = "${var.owner}-alb-${terraform.workspace}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${data.terraform_remote_state.vpc.alb_sg_id}"]
  subnets                    = ["${data.terraform_remote_state.vpc.public_subnets}"]
  enable_deletion_protection = false

  tags {
    evironment = "workshop"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_tg.arn}"
  }
}

