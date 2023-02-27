# define resource group
project_name = "trk-ppe-sbx"
project_loc  = "westcentralus"

image_gallery_name = "trk_ppe_sbx_img_gallery"
tags = {
  "environment" = "sandbox"
}

vmss_config = {
  instances      = 1,
  image_sku      = "Standard_F2",
  image_name     = "test",
  image_version  = "1.0.0",
  admin_username = "azureadm"
}