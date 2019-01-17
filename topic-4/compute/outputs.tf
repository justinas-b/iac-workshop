output "alb_dns_name" {
  value = "${aws_lb.load_balancer.dns_name}"
}

output "alb_id" {
  value = "${aws_lb.load_balancer.id}"
}

