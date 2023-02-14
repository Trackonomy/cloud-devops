#!/bin/bash

echo "Starting apps"
su - azureadm -c "cd /apis/node-dev && pm2 start filter/bin/www --name filter && 
pm2 start mobile/bin/www --name mobile && 
pm2 start util/bin/www --name util && 
pm2 start external/bin/www --name external && 
pm2 start health-dash/bin/www --name health-dash && 
pm2 start tapeevents/bin/www --name tapeevents && 
pm2 save && 
pm2 startup && 
pm2 save" 
exit 0