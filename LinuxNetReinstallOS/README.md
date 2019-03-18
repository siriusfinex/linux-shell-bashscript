+ 依赖包:
```
#二进制文件    Debian/Ubuntu    RedHat/CentOS
iconv         [libc-bin]       [glibc-common]
xz            [xz-utils]       [xz]
awk           [gawk]           [gawk]
sed           [sed]            [sed]
file          [file]           [file]
grep          [grep]           [grep]
openssl       [openssl]        [openssl]
cpio          [cpio]           [cpio]
gzip          [gzip]           [gzip]
cat,cut..     [coreutils]      [coreutils]
```

+ 确保安装了所需软件:
```
#Debian/Ubuntu:
apt-get install -y xz-utils openssl gawk file

#RedHat/CentOS:
yum install -y xz openssl gawk file
```

+ 如果出现了错误,请运行:
```
#Debian/Ubuntu:
apt-get update

#RedHat/CentOS:
yum update
```

+ 快速使用示例:
```
bash <(wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh') -d 8 -v 64 -a
```

+ 下载及说明:
```
wget --no-check-certificate -qO InstallNET.sh 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh' && chmod a+x InstallNET.sh
```
```
Usage:
        bash InstallNET.sh      -d/--debian [dist-name]
                                -u/--ubuntu [dist-name]
                                -c/--centos [dist-version]
                                -v/--ver [32/i386|64/amd64]
                                --ip-addr/--ip-gate/--ip-mask
                                -apt/-yum/--mirror
                                -dd/--image
                                -a/-m

# dist-name: 发行版本代号
# dist-version: 发行版本号
# -apt/-yum/--mirror : 使用定义镜像
# -a/-m : 询问是否能进入VNC自行操作. -a 为不提示(一般用于全自动安装), -m 为提示.
```

+ 使用示例:
```
#使用默认镜像全自动安装
bash InstallNET.sh -d 8 -v 64 -a

#使用自定义镜像全自动安装
bash InstallNET.sh -c 6.9 -v 64 -a --mirror 'http://mirror.centos.org/centos'


# 以下示例中,将X.X.X.X替换为自己的网络参数.
# --ip-addr :IP Address/IP地址
# --ip-gate :Gateway   /网关
# --ip-mask :Netmask   /子网掩码

#使用自定义镜像自定义网络参数全自动安装
#bash InstallNET.sh -u 16.04 -v 64 -a --ip-addr x.x.x.x --ip-gate x.x.x.x --ip-mask x.x.x.x --mirror 'http://archive.ubuntu.com/ubuntu'

#使用自定义网络参数全自动dd方式安装
#bash InstallNET.sh --ip-addr x.x.x.x --ip-gate x.x.x.x --ip-mask x.x.x.x -dd 'https://moeclub.org/onedrive/IMAGE/Windows/win7emb_x86.tar.gz'

#使用自定义网络参数全自动dd方式安装存储在谷歌网盘中的镜像(调用文件ID的方式)
#bash InstallNET.sh --ip-addr x.x.x.x --ip-gate x.x.x.x --ip-mask x.x.x.x -dd "https://image.moeclub.org/GoogleDrive/1cqVl2wSGx92UTdhOxU9pW3wJgmvZMT_J"

#使用自定义网络参数全自动dd方式安装存储在谷歌网盘中的镜像
#bash InstallNET.sh --ip-addr x.x.x.x --ip-gate x.x.x.x --ip-mask x.x.x.x -dd "https://image.moeclub.org/GoogleDrive/1cqVl2wSGx92UTdhOxU9pW3wJgmvZMT_J"

#国内推荐使用USTC源
#--mirror 'http://mirrors.ustc.edu.cn/debian/'
```

+ 一些可用镜像地址:
```
# 推荐使用带有 /GoogleDrive/ 链接, 速度更快.
# 当然也可以使用自己GoogleDrive中储存的镜像,使用方式:
  https://image.moeclub.org/GoogleDrive/

# win7emb_x86.tar.gz:
  https://image.moeclub.org/GoogleDrive/1srhylymTjYS-Ky8uLw4R6LCWfAo1F3s7 
  https://moeclub.org/onedrive/IMAGE/Windows/win7emb_x86.tar.gz

# win8.1emb_x64.tar.gz:
  https://image.moeclub.org/GoogleDrive/1cqVl2wSGx92UTdhOxU9pW3wJgmvZMT_J
  https://moeclub.org/onedrive/IMAGE/Windows/win8.1emb_x64.tar.gz

# win10ltsc_x64.tar.gz:
  https://image.moeclub.org/GoogleDrive/1OVA3t-ZI2arkM4E4gKvofcBN9aoVdneh
  https://moeclub.org/onedrive/IMAGE/Windows/win10ltsc_x64.tar.gz
```

