#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi

if [[ ! -e /etc/debian_version ]]; then
echo "Hanya bisa dijalankan di Debian"
exit
fi

VERSION=$(sed 's/\..*//' /etc/debian_version)
CODENAME=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)
if [ $VERSION -eq 8 ]
then
echo '
deb http://httpredir.debian.org/debian jessie main
deb http://httpredir.debian.org/debian jessie-updates main
deb http://security.debian.org/ jessie/updates main
' > /etc/apt/sources.list
fi

if [ $VERSION -eq 7 ]
then
echo '
deb http://httpredir.debian.org/debian wheezy main
deb http://httpredir.debian.org/debian wheezy-updates main
deb http://security.debian.org/ wheezy/updates main
' > /etc/apt/sources.list
fi

# hapus yang ngga perlu
apt-get purge exim4* rpcbind samba* -y

# Repostory nginx
wget -qO - http://nginx.org/keys/nginx_signing.key | apt-key add -
echo 'deb http://nginx.org/packages/mainline/debian/ '$CODENAME' nginx' >> /etc/apt/sources.list

## update repository dan sistem
apt-get clean all
apt-get update
apt-get upgrade -y

### update timezone  Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

## tambah US UTF8 sama Indonesia
## Biar format tanggal bisa menggunakan tanggal Indonesia
echo '
en_US.UTF-8 UTF-8
id_ID ISO-8859-1
id_ID.UTF-8 UTF-8
' > /etc/locale.gen
locale-gen en_US.UTF-8

### install ca-certificates biar wget ga protest ERROR: The certificate of xxxxxx
apt-get install bsdutils bash-completion nano dialog curl ca-certificates -y

# nano Syntax highlight
echo '
set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
include /usr/share/nano/nginx.nanorc
' >> ~/.nanorc
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# OpenSSH
apt-get install openssh-server -y

# konfigurasi ulang OpenSSH server'
dpkg-reconfigure openssh-server
## PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

# SSH
echo "UseDNS no" >> /etc/ssh/sshd_config
# Network Tools
apt-get install rsync htop rsnapshot vnstat mtr iperf curl unzip wget whois dnsutils strace ltrace zip -y

# NGINX
apt-get install nginx -y

# MYSQL
apt-get install mysql-server -y

# PHP
apt-get install php5 php5-common php5-gd php5-xmlrpc php5-fpm php5-curl php5-intl php5-mcrypt php5-imagick php5-mysqlnd -y

# GIT
apt-get install git -y

# Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Mengamankan /tmp
cd ~
rm -rf /tmp
mkdir /tmp
mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
chmod 1777 /tmp
echo "tmpfs   /tmp    tmpfs   rw,noexec,nosuid        0       0" >> /etc/fstab
rm -rf /var/tmp
ln -s /tmp /var/tmp

## Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

## Add public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys
