resource "azurerm_redis_cache" "redis" {
    name = "redis-events-${var.env_prefix}"
    location = azurerm_resource_group.rg_eventsprimary.location
    resource_group_name = azurerm_resource_group.rg_eventsprimary.name
    capacity = var.redis_cap
    family = var.redis_family
    sku_name = var.redis_sku

    enable_non_ssl_port = false
    minimum_tls_version = 1.2

    redis_version = 6
    zones = var.availability_zones
    shard_count = var.sku_name == "Premium" ? var.shard_count : null

    maxmemory_policy = "volatile-lru"
    maxmemory_reserved = 125
    maxfragmentationmemory_reserved = 125

    tags = {
      "application" = "events",
      "env" = "${var.env_prefix}"
    }
}