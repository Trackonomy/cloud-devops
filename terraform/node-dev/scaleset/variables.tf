variable "subscription_id" {
  description = "Subscription which we want to use"
  type        = string
}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "project_name" {
  description = "What name prefix will be used in all resources during their creation."
  type        = string
}

variable "project_loc" {
  description = "Main region of our project."
  type        = string
}

variable "image_gallery_name" {
  description = "Name of the vm gallery. Can only contain alphanumeric, full stops and underscores"
  type        = string
}

variable "accepted_ports" {
  description = "Ports which we would like to open. Structure [ port => priority ]."
  type        = map(string)
  default = {
    "8098" = 110,
    "8191" = 120,
    "8491" = 130,
    "9091" = 140,
    "9111" = 150,
    "9000" = 160,
    "9003" = 170
  }
}

variable "tags" {
  description = "Specify all standard tags you want."
  type        = map(string)
}


variable "vmss_config" {
  description = "Configuration of VM in scaleset"
  type        = map(string)
  default = {
    instances                       = 1,
    image_sku                       = "Standard_D2s_v3",
    image_name                      = "test",
    image_version                   = "1.4.0",
    admin_username                  = "azureadm",
    disable_password_authentication = false,
    admin_ssh_key                   = "ssh-rsa key",
    admin_password                  = "qwerty12345"
  }
}

variable "dns_prefix" {
  description = "DNS prefix of public ip"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones of virtual machines"
  type        = set(string)
  default     = null
}

variable "lb_name" {
  description = "Load balancer name for the scaleset."
  type        = string
  default     = ""
}

variable "pubip_name" {
  description = "Public ip name of the scaleset"
  type        = string
  default     = ""
}

variable "nsg_name" {
  description = "Network security group name"
  type        = string
  default     = ""
}

variable "scaleset_name" {
  description = "Name of the scaleset"
  type        = string
  default     = ""
}