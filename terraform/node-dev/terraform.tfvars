# define resource group
project_name = "trk-ppe-sbx"
project_loc  = "West US"

image_gallery_name = "trk_ppe_sbx_img_gallery"
tags = {
    "environment" = "sandbox"
}

vmss_config = {
    instances = 1,
    image_sku = "Standard_F2",
    image_name = "test",
    image_version = "1.0.0",
    admin_username = "azureadm",
    disable_password_authentication = true,
    admin_ssh_key = "ssh-rsa key",
    admin_password = "qwerty12345"
}


accepted_ports = {
    "8098" = 110,
    "8191" = 120,
    "8491" = 130,
    "9091" = 140,
    "9111" = 150,
    "9000" = 160,
    "9003" = 170
} 

#8122, 4183, 8123