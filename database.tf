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
    security_groups = ["${aws_security_group.db_host.id}"]
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