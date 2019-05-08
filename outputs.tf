output "DB Host Address" {
  value = "${aws_route53_record.skreisig.*.name}"
}

output "ELB DNS name" {
  value = "${aws_elb.elb.dns_name}"
}