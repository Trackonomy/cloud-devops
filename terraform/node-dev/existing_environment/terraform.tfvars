project_name = "rg-trkuni-ppe-genvm"
image_gallery_name = "unippe_img_gallery"
scaleset_name = "vmss-uni-ppe-genvm"
nic_name = "rgtrkunippegenvmvnet759-nic01"
subnet_name = "default"
vn_name = "rgtrkunippegenvmvnet759"
ipconf_name = "rgtrkunippegenvmvnet759-nic01-defaultIpConfiguration"
lb_name = "vmsslb-unippe-genvm"
bepool_name = "vmsslb-ppe-beppol"
availability_zones = ["1","3","2"]
vmss_config = {
  instances      = 2,
  image_sku      = "Standard_D8s_v3",
  image_name     = "unippeImgDef",
  image_version  = "2.8.2",
  admin_username = "azureadm",
  admin_password = "Qwerty12345@"
}