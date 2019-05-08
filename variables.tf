
variable "prefix" {
  default = "skreisig"
}
variable "azs" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "db_password" {
  description = "Enter db password:"
  default = "somePassword"
}

variable "hostnames" {
  description = "hostnames"
  type = "list"
  default = ["skreisig","iamgroot"]#, "jambit", "dev", "sandbox"]
}
