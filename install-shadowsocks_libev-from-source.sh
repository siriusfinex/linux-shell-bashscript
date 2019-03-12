#! /bin/bash
#
#make git directory
if [ ! -d "~/git" ]; then
	mkdir ~/git
fi
if [ ! -d "~/git/shadowsocks-libev" ]; then
	mkdir ~/git/shadowsocks-libev
fi

#install dependencies
apt install -y build-essential autoconf libtool libssl-dev
apt install -y gawk debhelper dh-systemd init-system-helpers pkg-config git

#download and install shadowsocks-libev
cd ~/git/shadowsocks-libev
ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest | grep 'tag_name' | cut -d\" -f4)
[ -z ${ver} ] && echo "Error: Get shadowsocks-libev latest version failed" && exit 1
shadowsocks_libev_ver="shadowsocks-libev-$(echo ${ver} | sed -e 's/^[a-zA-Z]//g')"
download_link="https://github.com/shadowsocks/shadowsocks-libev/releases/download/${ver}/${shadowsocks_libev_ver}.tar.gz"
wget -qO "${shadowsocks_libev_ver}.tar.gz" "${download_link}"
tar zxf ${shadowsocks_libev_ver}.tar.gz
mkdir -p ~/build-area/
cp ./scripts/build_deb.sh ~/build-area/
cd ~/build-area
./build_deb.sh
