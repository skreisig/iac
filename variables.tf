variable "prefix" {
  description = "jambit username"
  default = "skreisig"
}

variable "hostnames" {
  description = "hostnames"
  type = "list"
  default = ["skreisig","iamgroot", "jambit", "dev", "sandbox"]
}