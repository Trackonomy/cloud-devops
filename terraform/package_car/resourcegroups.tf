resource "azurerm_resource_group" "rg_funccache" {
    name = "rg-funccache${var.rg_prefix}"
    location = var.location   
}

resource "azurerm_resource_group" "rg_funcevent" {
  name = "rg-funcevent${var.env_prefix}"
  location = var.location
}

resource "azurerm_resource_group" "rg_funcrawevent" {
    name = "rg-funcrawevent${var.env_prefix}"
    location = var.location
}

resource "azurerm_resource_group" "rg_eventsprimary" {
  name = "rg-events-primary"
  location = var.location
}