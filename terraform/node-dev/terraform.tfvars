# define resource group
project_name = "trk-ppe-sbx"
project_loc  = "westus"

image_gallery_name = "trk_ppe_sbx_img_gallery"
tags = {
  "environment" = "sandbox"
}

vmss_config = {
    instances                       = 1,
    image_sku                       = "Standard_F2",
    image_name                      = "test",
    image_version                   = "1.0.0",
    admin_username                  = "azureadm",
    disable_password_authentication = true,
    admin_ssh_key                   = "AAAAB3NzaC1yc2EAAAADAQABAAABgQC0dMDXoFOTE1VEDyRE3Ik8H6vPc9wdMFjtCvfItY6YnCONxxudQ1vadwltCpz2KkI/WT7pRbTTbl8jd3Gli+BbFb2YMJey59Vn0Zs+oRSmPl/F7ZVLKp4QSCpUm8/9jRqR61RG8W2lTUeJhJX65uVH83KM5iEjUEUGk/GAzSAKtB50HEMyho27fSqPqOtCvdmdcIonesoeyuWnQOF15t6aoGVn6h6ulnATrGe3WkXI5VrXDCdJc/ueimrSGvclELUNGm5xrwgAp428gk85hZblg9bSODWUVlAKDAsGZvWFaHMhG1tQzfVknlReCBXKLI7m070U/RmU7+syCFaKCM6uVhJGJ964NLamjvsNgvlLO/ZHdV+HxV3h118NmvHTlriMW/8ZSKC124v+A2I5eTP1rL/+HWqBL9SYhCPNlcM8yWZ1nx5Uk4g793H0Qap/C0WxdJAOTJiMqm3N0DjcWMNXS4HpiwyLjL9UCqo7oo/xoSABI9i55aKe1d4+v7EYXqM=",
    admin_password                  = "qwerty12345"
}


#8122, 4183, 8123