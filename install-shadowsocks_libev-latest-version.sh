#! /bin/bash
#
#before install shadowsocks-libev
echo "Before install shadowsocks-libev,you should install following dependencies:"
echo "run the command 'apt install -y build-essential autoconf libtool libssl-dev gawk debhelper dh-systemd init-system-helpers pkg-config git' to install"

#make git directory
if [ ! -d "/root/git" ]; then
        mkdir /root/git
else
        echo "ok"
fi
if [ ! -d "/root/git/shadowsocks-libev" ]; then
        mkdir /root/git/shadowsocks-libev
else
        echo "ok"
fi
if [ ! -d "/root/build-area" ]; then
        echo "ok"
else
        rm -rf /root/build-area
fi

#download and install shadowsocks-libev
cd ~/git/shadowsocks-libev
ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest | grep 'tag_name' | cut -d\" -f4); [ -z ${ver} ] && echo "Error: Get shadowsocks-libev latest version failed" && exit 1
shadowsocks_libev_ver="shadowsocks-libev-$(echo ${ver} | sed -e 's/^[a-zA-Z]//g')"
download_link="https://github.com/shadowsocks/shadowsocks-libev/releases/download/${ver}/${shadowsocks_libev_ver}.tar.gz"
wget -qO "${shadowsocks_libev_ver}.tar.gz" "${download_link}"
tar zxf ${shadowsocks_libev_ver}.tar.gz
mkdir -p ~/build-area/
cp ./${shadowsocks_libev_ver}/scripts/build_deb.sh ~/build-area/
cd ~/build-area
./build_deb.sh
