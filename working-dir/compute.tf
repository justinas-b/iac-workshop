# Defining some local variables
locals {
  compute_subnets = ["${aws_subnet.private.*.id}"]
  alb_subnets     = ["${aws_subnet.public.*.id}"]
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
    db_endpoint = "${aws_db_instance.default.address}"
  }
}

resource "aws_launch_configuration" "as_conf" {
  name            = "${var.owner}-lc-${terraform.workspace}"
  image_id        = "${data.aws_ami.ami.id}"
  instance_type   = "t2.micro"
  key_name        = "${var.key_pair}"
  user_data       = "${data.template_file.init.rendered}"
  security_groups = ["${aws_security_group.asg.id}"]

  // Issue: https://github.com/hashicorp/terraform/issues/11349#issuecomment-437561823 
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.owner}-asg-${terraform.workspace}"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 0
  max_size             = 4
  desired_capacity     = 2
  target_group_arns    = ["${aws_lb_target_group.alb_tg.arn}"]
  vpc_zone_identifier  = ["${local.compute_subnets}"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances", 
    "GroupPendingInstances",
    "GroupStandbyInstances", 
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "${local.generic_tag}-asg-policy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }
  target_value = 40.0
  }
}

//-----------------------------------------
// ALB
//-----------------------------------------
resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.owner}-lb-tg-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_lb" "load_balancer" {
  name                       = "${var.owner}-alb-${terraform.workspace}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.alb.id}"]
  subnets                    = ["${local.alb_subnets}"]
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

//-----------------------------------------
// ALB Security Group and rules
//-----------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.owner}-alb-${terraform.workspace}"
  description = "Allow http traffic"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "public_access" {
  description       = "Allow public ingress traffic"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "lb_to_ec2" {
  description              = "Forward traffic from ALB to EC2"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.asg.id}"
  security_group_id        = "${aws_security_group.alb.id}"
}

//-----------------------------------------
// ASG Security Group and rules
//-----------------------------------------
resource "aws_security_group" "asg" {
  name        = "${var.owner}-asg-${terraform.workspace}"
  description = "Allow user SSH and ALB traffic"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "ssh_access" {
  description       = "Allow SSH access"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.asg.id}"
}

resource "aws_security_group_rule" "lb_2_ec2" {
  description              = "Allow web traffic from ALB"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.asg.id}"
  source_security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "ec2_2_lb" {
  description              = "Traffic from EC2 to ALB"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb.id}"
  security_group_id        = "${aws_security_group.asg.id}"
}

resource "aws_security_group_rule" "ec2_2_public" {
  description       = "Traffic from EC2 to ALB"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.asg.id}"
}
