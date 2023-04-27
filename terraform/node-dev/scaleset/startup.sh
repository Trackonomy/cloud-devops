#!/bin/bash

start_all() {
  save_startup_file() {
    sudo tee -a /etc/systemd/system/pm2-{username}.service <<- EOF
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User={username}
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
Environment=PM2_HOME=/home/{username}/.pm2
PIDFile=/home/{username}/.pm2/pm2.pid
Restart=on-failure

ExecStart=/usr/lib/node_modules/pm2/bin/pm2 resurrect
ExecReload=/usr/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/usr/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target
EOF
}
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 50M
pm2 set pm2-logrotate:retain 10
pm2 set pm2-logrotate:compress true
cd /apis/node-dev && pm2 start filter/bin/www --name filter {filter.params}
pm2 start mobile/bin/www --name mobile {mobile.params}
pm2 start util/bin/www --name util {util.params}
pm2 start external/bin/www --name external {external.params}
pm2 start health-dash/bin/www --name health-dash {health-dash.params}
pm2 start tapeevents/bin/www --name tapeevents {tapeevents.params}
{additional.params}
pm2 save
save_startup_file
sudo systemctl enable pm2-{username}.service
pm2 save
}
export -f start_all
echo "Starting apps"

su {username} -c "bash -c start_all" 
exit 0
