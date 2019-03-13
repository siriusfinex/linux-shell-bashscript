#! /bin/bash
#
ssmgr_key=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/siriusfinex/api/master/ssmgr/ssmgr-tiny/auto-upgrade-task | grep 'key' | cut -d\" -f4)
ssmgr_date=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/siriusfinex/api/master/ssmgr/ssmgr-tiny/auto-upgrade-task | grep 'date' | cut -d\" -f4)
if [[ "$ssmgr_key" -eq "1" ]] && [[ "ssmgr_date" -eq "`date +%Y%m%d`" ]]; then
        rm -rf /root/shadowsocks-manager-tiny && cd /root && git clone https://github.com/gyteng/shadowsocks-manager-tiny.git
fi

ss_key=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/siriusfinex/api/master/shadowsocks/shadowsocks-libev/auto-upgrade-task | grep 'key' | cut -d\" -f4)
ss_date=$(wget --no-check-certificate -qO- https://raw.githubusercontent.com/siriusfinex/api/master/shadowsocks/shadowsocks-libev/auto-upgrade-task | grep 'date' | cut -d\" -f4)
if [[ "$ss_key" -eq "1" ]] && [[ "$ss_date" -eq "`date +%Y%m%d`" ]]; then
        cd /root && bash <(curl -s -S -L "https://raw.githubusercontent.com/siriusfinex/linux-shell-bashscript/master/install-shadowsocks_libev-latest-version.sh")
fi
