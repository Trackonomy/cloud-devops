variable "subscription_id" {
  description = "Subscription which we want to use"
  type = string
}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "rg_name" {
  description = "Resource group which we would like to use"
  type = string
  default = ""
}

variable "rg_loc" {
  description = "Resource group location which we would like to use"
  type = string
  default = ""
}

