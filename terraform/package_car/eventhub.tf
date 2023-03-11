resource "azurerm_eventhub_namespace" "eventhubns" {
    name = "evhns-events-${var.env_prefix}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg_eventsprimary.name
    sku = var.eventhub_sku
    minimum_tls_version = 1.2

    zone_redundant = var.eventhub_sku == "Premium" ? var.eventhub_zone_redundant : false

    auto_inflate_enabled = false
    tags = {
        "application" = "events"
        "env" = "${var.env_prefix}"
    }
}

resource "azurerm_eventhub" "eventhub" {
    name = "evh-events-${var.env_prefix}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg_eventsprimary.name
    namespace_name = azurerm_eventhub_namespace.eventhubns.name
    partition_count = var.eventhub_sku == "Premium" ? var.partition_count : null
    message_retention = var.message_retention
    capture_description {
      enabled = true
      encoding = "Avro"
      interval_in_seconds = 900
      size_limit_in_bytes = 314572800
      destination {
        name = "EventhubArchive.AzureBlockBlob"
        archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        blob_container_name = "events-raw"
        storage_account_id = azurerm_storage_account.evhub_stacc.id
      }
    }
}

resource "azurerm_storage_account" "evhub_stacc" {
    name = "steventsdata001"
    resource_group_name = azurerm_resource_group.rg_eventsprimary.name
    location = var.location
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "RAGRS"
    access_tier = "Cool"
    min_tls_version = "TLS1_2"
    

}