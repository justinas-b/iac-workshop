output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "alb_dns_name" {
  value = "${aws_lb.load_balancer.dns_name}"
}

output "alb_id" {
  value = "${aws_lb.load_balancer.id}"
}

output "db_endpoint" {
  value = "${aws_db_instance.default.address}"
}

output "db_port" {
  value = "${aws_db_instance.default.port}"
}
