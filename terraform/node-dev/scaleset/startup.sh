#!/bin/bash

start_all() {
  save_startup_file() {
    sudo tee -a /etc/systemd/system/pm2-prdazureadmin.service <<- EOF
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=prdazureadmin
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
Environment=PM2_HOME=/home/prdazureadmin/.pm2
PIDFile=/home/prdazureadmin/.pm2/pm2.pid
Restart=on-failure

ExecStart=/usr/lib/node_modules/pm2/bin/pm2 resurrect
ExecReload=/usr/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/usr/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target
EOF
}

cd /apis/node-dev && pm2 start filter/bin/www --name filter -i max
pm2 start mobile/bin/www --name mobile
pm2 start util/bin/www --name util
pm2 start external/bin/www --name external
pm2 start health-dash/bin/www --name health-dash
pm2 start tapeevents/bin/www --name tapeevents
pm2 save
save_startup_file
sudo systemctl enable pm2-prdazureadmin.service
pm2 save
}
export -f start_all
echo "Starting apps"

su prdazureadmin -c "bash -c start_all" 
exit 0
