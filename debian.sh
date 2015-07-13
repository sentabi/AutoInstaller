#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi


if [[ ! -e /etc/debian_version ]]; then
echo "Hanya bisa dijalankan di Debian atau turunannya"
exit
fi

VERSION=$(sed 's/\..*//' /etc/debian_version)

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



## buat folder SSH
mkdir ~/.ssh
## public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys

## update repository dan sistem
apt-get clean all
apt-get update
apt-get upgrade -y

### update timezone  Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

## ubah locale jadi US UTF8
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen en_US.UTF-8

### install install untuk kebutuhan awal
### install ca-certificates biar wget ga protest ERROR: The certificate of xxxxxx
apt-get install bsdutils bash-completion nano curl wget dialog ca-certificates -y

# konfigurasi ulang settingan ssh server'
dpkg-reconfigure openssh-server
## PS1 
echo 'PS1="\[\e[1;30m\][\[\e[1;31m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
. ~/.bashrc

## mengamankan /tmp
rm -rf /tmp
mkdir /tmp
mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
chmod 1777 /tmp
echo "tmpfs   /tmp    tmpfs   rw,noexec,nosuid        0       0" >> /etc/fstab
rm -rf /var/tmp
ln -s /tmp /var/tmp  

