// public instance to access the database

data "aws_ami" "db_ami" {
  most_recent = true
  owners = [
    "self",
    "287283636362"]

  filter {
    name = "name"
    values = [
      "nodejs-rds-demo-*"]
  }
  filter {
    name = "state"
    values = [
      "available"]
  }
}

resource "aws_instance" "db_host" {

  count = "${length(var.hostnames)}"

  user_data = <<EOT
    #cloud-config
    preserve_hostname: false
    manage_etc_hosts: true
    hostname: ${var.hostnames[count.index]}-${count.index + 1}
    fqdn: ${var.hostnames[count.index]}-${count.index + 1}
  EOT

  ami = "${data.aws_ami.db_ami.id}"
  instance_type = "t3.small"

  associate_public_ip_address = true
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  key_name = "${var.prefix}"
  vpc_security_group_ids = [
    "${aws_security_group.db_host.id}"
  ]

  tags {
    Name = "${var.prefix}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/Users/skreisig/.ssh/id_rsa")}"
  }

  # Copies the string in content into /tmp/file.log
  provisioner "file" {
    content = <<EOT
      #db_variables
      DB_HOST="${aws_db_instance.my_db.address}"
      DB_DB="${aws_db_instance.my_db.name}"
      DB_USER="${aws_db_instance.my_db.username}"
      DB_PASS="${aws_db_instance.my_db.password}"
    EOT
    destination = "/tmp/nodejs.env"
  }

  provisioner "remote-exec" {
    script = "scripts/config_env.sh"
  }
}

data "aws_route53_zone" "db_host" {
  name = "iac.trainings.jambit.de"
}

resource "aws_route53_record" "skreisig" {
  count = "${length(var.hostnames)}"

  zone_id = "${data.aws_route53_zone.db_host.zone_id}"
  name = "${var.hostnames[count.index]}.${data.aws_route53_zone.db_host.name}"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.db_host.*.public_ip[count.index]}"]
}

resource "aws_security_group" "db_host" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}"
  }

}