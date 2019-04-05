#!/bin/bash
pm2 -V || npm i -g pm2
supervisorctl stop all && rm -rf ~/shadowsocks-manager-tiny ~/.shadowsocks /etc/supervisor/conf.d/* && supervisorctl reload
git clone https://github.com/siriusfinex/shadowsocks-manager-tiny.git
pm2 --name "serverstatus-client" -f start ~/client-linux.py
pm2 --name "ssmgr-tiny" -f start ~/shadowsocks-manager-tiny/index.js -x -- -s 127.0.0.1:6000 -m 0.0.0.0:6086 -p wx3898749 -r libev:chacha20-ietf-poly1305 -d ~/shadowsocks-manager-tiny/data.json
pm2 save && pm2 startup
sed -i 's/supervisorctl/pm2/g' /etc/crontab
