variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "location" {
  description = "Location of a project"
  type = string
}
variable "env_prefix" {
    description = "Environment prefix"
    type = string
}
variable "redis_cap" {
    description = "The size of redis cache to deploy"
    type = number
}
variable "redis_family" {
  description = "The SKU family/pricing group to use. Values: C or P"
  type = string
}

variable "redis_sku" {
    description = "The SKU redis use. Possible values: Basic, Standard, Premium"
    type = string
}

variable "availability_zones" {
    description = "Availability Zones for Azure resources"
    type = set(string)
    default = null
}

variable "shard_count" {
  description = "Number of shards for redis. Available only in Premium tier."
  type = string
  default = null
}

variable "eventhub_sku" {
    description = "SKU for eventhub. Valid values: Basic, Standard, Premium."
    type = string
}

variable "eventhub_zone_redundant" {
  description = "Zone redundancy for Premium SKU. Default value is true"
  type = bool
  default = true
}

variable "partition_count" {
  description = "Number of partitions for eventhub"
  type = number
}

variable "message_retention" {
  description = "Number of days for message retention"
  type = number
}