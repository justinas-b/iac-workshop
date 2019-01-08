output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_compute_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_db_subnets" {
  value = ["${aws_subnet.db_private.*.id}"]
}

output "alb_sg_id" {
  value = "${aws_security_group.alb.id}"
}

output "asg_sg_id" {
  value = "${aws_security_group.asg.id}"
}