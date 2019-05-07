output "DB Host Address" {
  value = "${aws_route53_record.skreisig.*.name}"
}