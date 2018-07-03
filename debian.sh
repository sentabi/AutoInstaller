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
# CODENAME atau $(lsb_release -sc)
CODENAME=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)

apt-get install wget sudo openssh-server curl nano dialog -y

# konfigurasi ulang OpenSSH server'
dpkg-reconfigure openssh-server

# SSH
echo "UseDNS no" >> /etc/ssh/sshd_config

## Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

## Add public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys

# hapus yang ngga perlu
apt-get purge exim4* rpcbind samba* -y


## Add public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys

# Repository SURY
apt-get install apt-transport-https lsb-release ca-certificates -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Repostory mainline nginx
wget -qO - http://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb http://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list

## update repository dan sistem
apt-get clean all
apt-get update
apt-get upgrade -y

### update timezone  Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
echo 'Asia/Jakarta' > /etc/timezone

## tambah US UTF8 sama Indonesia
## Biar format tanggal bisa menggunakan tanggal Indonesia
echo '
en_US.UTF-8 UTF-8
id_ID ISO-8859-1
id_ID.UTF-8 UTF-8
' > /etc/locale.gen
locale-gen en_US.UTF-8

# install ca-certificates biar wget ga protest ERROR: The certificate of xxxxxx
apt-get install bsdutils bash-completion -y

# karna ifconfig itu penting ;)
apt-get install net-tools -y

# nano Syntax highlight
echo '
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
include /usr/share/nano/nginx.nanorc
' >> ~/.nanorc
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc



# Network Tools
apt-get install rsync htop rsnapshot vnstat mtr iperf unzip whois dnsutils strace ltrace zip -y

# NGINX
apt-get install nginx -y

apt-get install pwgen -y

# MYSQL
apt-get install mariadb-server mariadb-client -y
MYSQL_ROOT_PASSWORD=$(pwgen 15 1)
systemctl start mysql
# MARIADB disable Unix Socket authentication
# https://mariadb.com/kb/en/library/authentication-plugin-unix-socket/

mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE test;"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "UPDATE mysql.user set plugin='' where User='root';"

# PHP 7
apt-get install php7.1 php7.1-cli php7.1-common php7.1-gd php7.1-xmlrpc php7.1-fpm php7.1-curl php7.1-intl php7.1-mcrypt php7.1-imagick php7.1-mysqlnd php7.1-zip php7.1-xml php7.1-mbstring  -y

sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Jakarta/g' /etc/php/7.1/fpm/php.ini
sed -i 's/disable_functions =/disable_functions =dl,exec,passthru,proc_open,proc_close,shell_exec,system/g'

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

echo "[client]
user = root
password = $MYSQL_ROOT_PASSWORD" > ~/.my.cnf

# Script Autobackup MySQL
mkdir -p /backup/mysql

echo '#!/bin/bash
backup_path=/backup/mysql
expired=5
tgl=$(date +%Y-%m-%d)

if [ ! -d "$backup_path" ]
    then
        mkdir "$backup_path"
fi

if [ ! -d "$backup_path/$tgl" ]
then
    mkdir -p "$backup_path/$tgl"
    if [ ! -f $backup_path/$tgl/db-$(date +%H%M).sql ]
    then
            mysqldump --all-databases | gzip -c > $backup_path/$tgl/db-$(date +%H%M).sql
    fi
else
    if [ ! -f $backup_path/$tgl/db-$(date +%H%M).sql ]
    then
            mysqldump --all-databases | gzip -c > $backup_path/$tgl/db-$(date +%H%M).sql
    fi
    # echo $tgl " File sudah ada."
fi
# hapus bila lebih dari nilai expired day
find $backup_path -type d -mtime +$expired | xargs rm -Rf
' > /backup/mysql/backup-mysql.sh
chmod +x /backup/mysql/backup-mysql.sh
echo "@hourly /backup/mysql/backup-mysql.sh" >> /var/spool/cron/root

# WP CLI
WPCLI='/usr/local/bin/wp'
if [ ! -f $WPCLI ]; then
    echo "---------------------------"
    echo "Download & Install WPCLI ... "
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
    chmod +x /usr/local/bin/wp
    echo "Install WPCLI selesai!"
    echo "---------------------------"
fi

echo '----------------------'
echo "Password root MySQL: " "$MYSQL_ROOT_PASSWORD"
echo '----------------------'
