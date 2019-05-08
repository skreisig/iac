// Elastic load balancer

# Create a new load balancer
resource "aws_elb" "elb" {
  name = "${var.prefix}-terraform-elb"

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.iac.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 30
  }

  instances = [
    "${aws_instance.db_host.*.id}"]

  tags = {
    Name = "foobar-terraform-elb"
  }

  subnets = [
    "${aws_subnet.public.*.id}"]
  security_groups = [
    "${aws_security_group.elb.id}"]
}

data "aws_route53_zone" "db_host" {
  name = "iac.trainings.jambit.de"
}

resource "aws_route53_record" "skreisig" {
  zone_id = "${data.aws_route53_zone.db_host.zone_id}"
  name = "${var.prefix}.${data.aws_route53_zone.db_host.name}"
  type = "A"

  alias {
    name = "${aws_elb.elb.dns_name}"
    zone_id = "${aws_elb.elb.zone_id}"
    evaluate_target_health = true
  }
}

data "aws_acm_certificate" "iac" {
  domain      = "*.iac.trainings.jambit.de"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_security_group" "elb" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}-elb"
  }
}