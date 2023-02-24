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

variable "image_gallery_name" {
  description = "Name of the vm gallery. Can only contain alphanumeric, full stops and underscores"
  type        = string
}

variable "scaleset_name" {
  description = "Name of the scaleset"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "Availability zones of virtual machines"
  type        = set(string)
  default     = null
}

variable "nic_name" {
    description = "Name of the network interface"
    type        = string
}

variable "subnet_name" {
    description = "Name of the subnet"
    type        = string
}
variable "vn_name" {
    description = "Name of the virtual network"
    type        = string
}

variable "ipconf_name" { 
    description = "Ip configuration of scaleset name"
    type        = string
}

variable "lb_name" {
  description = "Load balancer name for the scaleset."
  type        = string
  default     = ""
}

variable "bepool_name" {
    description = "Backend pool name"
    type        = string
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