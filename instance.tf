data "aws_ami" "demo-ami" {
  most_recent = true
  owners = [
    "self",
    "287283636362"]

  filter {
    name = "name"
    values = [
      "nodejs-demo-*"]
  }
  filter {
    name = "state"
    values = [
      "available"]
  }
}

resource "aws_instance" "demo" {

  count = 30
  #"${length(var.hostnames)}"

  user_data = <<EOT
    #cloud-config
    preserve_hostname: false
    manage_etc_hosts: true
    hostname: "demo-${count.index}"
    fqdn: "demo-${count.index}"
  EOT
  #hostname = ${var.hostnames[count.index]}-${count.index + 1}

  ami = "${data.aws_ami.demo-ami.id}"
  instance_type = "t3.small"

  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.subnet.id}"

  key_name = "${var.prefix}"
  vpc_security_group_ids = [
    "${aws_security_group.demo.id}"
  ]

  tags {
    Name = "${var.prefix}"
  }
}

resource "null_resource" "test" {
  count = "${aws_instance.demo.count}"
  #"${length(var.hostnames)}"

  triggers {
    aws_instances = "${join(",", aws_instance.demo.*.id)}"
  }

  connection {
    host = "${aws_instance.demo.*.public_ip[count.index]}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/Users/skreisig/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    script = "scripts/dbspaming.sh"
  }
}
/*
data "aws_route53_zone" "demo" {
  name = "iac.trainings.jambit.de"
}

resource "aws_route53_record" "skreisig" {
  count = "${length(var.hostnames)}"

  zone_id = "${data.aws_route53_zone.demo.zone_id}"
  name = "${var.hostnames[count.index]}.${data.aws_route53_zone.demo.name}"
  type = "A"
  ttl = "60"
  records = [
    "${aws_instance.demo.*.public_ip[count.index]}"]
}*/

resource "aws_security_group" "demo" {
  vpc_id = "${data.aws_vpc.vpc.id}"

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