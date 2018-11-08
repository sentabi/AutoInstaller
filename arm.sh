#!/usr/bin/env bash
# Debian/Ubuntu ARM

if ! [[ -z "$1" ]]; then
        hostnamectl set-hostname --static $1
else
        hostnamectl set-hostname --static pi
fi

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi

if [[ ! -e /etc/debian_version ]]; then
    echo "Hanya bisa dijalankan di Debian"
    exit
fi

# update repository dan sistem
apt-get clean all
apt-get update
apt-get upgrade -y

# update timezone  Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
echo "Asia/Jakarta" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# tambah US UTF8 sama Indonesia
# Biar format tanggal bisa menggunakan tanggal Indonesia
echo '
en_US.UTF-8 UTF-8
id_ID ISO-8859-1
id_ID.UTF-8 UTF-8
' > /etc/locale.gen
locale-gen en_US.UTF-8

# install ca-certificates biar wget ga protest ERROR: The certificate of xxxxxx
apt-get install wget bsdutils bash-completion nano dialog curl ca-certificates -y

# nano Syntax highlight
echo '
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
include /usr/share/nano/nginx.nanorc
' >> ~/.nanorc
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# konfigurasi ulang OpenSSH server'
dpkg-reconfigure openssh-server

# PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

# SSH
echo "UseDNS no" >> /etc/ssh/sshd_config

# Network Tools
apt-get install rsync htop rsnapshot vnstat mtr iperf curl unzip openvpn whois dnsutils traceroute strace ltrace zip -y

# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

# Add public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys