output "A-Record-Name" {
  value = "${aws_route53_record.skreisig.*.name}"
}