// Databes instance

resource "aws_db_instance" "my_db" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.small"
  name = "${var.prefix}db"
  username = "${var.prefix}"
  password = "${var.db_password}"
  skip_final_snapshot = true
  vpc_security_group_ids = [
    "${aws_security_group.my_db.id}"]
  port = 3306
  db_subnet_group_name = "${aws_db_subnet_group.my_db.name}"
  identifier = "${var.prefix}"
}

resource "aws_db_subnet_group" "my_db" {
  name = "${var.prefix}-db-subnet"
  subnet_ids = [
    "${aws_subnet.private.*.id}"]

  tags = {
    Name = "${var.prefix}-db"
  }
}

resource "aws_security_group" "my_db" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
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
    Name = "RDS Instance"
  }
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name = "${var.prefix}-terraform-elb"

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
/*
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }
*/
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
  security_groups = ["${aws_security_group.elb.id}"]
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