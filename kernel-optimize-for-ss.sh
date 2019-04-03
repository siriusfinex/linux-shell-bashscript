#! /bin/bash
dir="/etc/sysctl.d/local.conf"
if [[ ! -f "$dir" ]]; then
        echo "ok"
else
        rm -rf "$dir" && echo "delete local.conf file"
fi

var_a=$(grep -o "^net.ipv4.tcp" /etc/sysctl.conf | wc -l)
var_b=$(grep -o "^net.core" /etc/sysctl.conf | wc -l)
var_c=`expr $var_a + $var_b`
if [[ "$var_c" -ge "17" ]]; then
        echo "ok"
else
echo "
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf

echo "* soft nofile 51200
* hard nofile 51200" >> /etc/security/limits.conf
ulimit -n 51200 && ulimit -n 51200
fi
sysctl -p
