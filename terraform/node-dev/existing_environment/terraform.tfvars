project_name = "trk-ppe-sbx"
image_gallery_name = "trk_ppe_sbx_img_gallery"
scaleset_name = "vmss-second"
nic_name = "vmss-second-nic"
subnet_name = "trk-ppe-sbx-sub01"
vn_name = "trk-ppe-sbx-vnet"
ipconf_name = "vmss-second-nic-defaultIpConfiguration"
lb_name = "trk-ppe-sbx-loadbalancer"
bepool_name = "vmss-second-bepool"
#availability_zones = ["1","3","2"]
vmss_config = {
  instances      = 1,
  image_sku      = "Standard_DS3_v2",
  image_name     = "test",
  image_version  = "1.5.0",
  admin_username = "azureadm",
  admin_password = "Qwerty12345@"
}