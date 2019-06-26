#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi

if [[ ! -e /etc/debian_version ]]; then
    echo "Hanya bisa dijalankan di Debian"
    exit
fi

# Add public_key
wget https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys
# OpenSSH server'
dpkg-reconfigure openssh-server
echo "UseDNS no" >> /etc/ssh/sshd_config
# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

DEBIAN_CODENAME=$(lsb_release -sc)
if [ -z $DEBIAN_CODENAME ]; then
    DEBIAN_CODENAME=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)
fi

if [ -z $DEBIAN_CODENAME ]; then
    DEBIAN_CODENAME=$(dpkg --status tzdata|grep Provides|cut -f2 -d'-')
fi

if [ -z $DEBIAN_CODENAME ]; then
    echo "Codename Debian tidak ditemukan."
    exit 1
fi

# default repository Debian
cat >/etc/apt/sources.list <<EOL
deb http://deb.debian.org/debian/ $DEBIAN_CODENAME main
deb-src http://deb.debian.org/debian/ $DEBIAN_CODENAME main
deb http://security.debian.org/debian-security $DEBIAN_CODENAME/updates main
deb-src http://security.debian.org/debian-security $DEBIAN_CODENAME/updates main
deb http://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main
deb-src http://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main
EOL

# Update Repository dan upgrade system
apt-get update; apt upgrade -y

apt-get install apt-transport-https lsb-release ca-certificates bsdutils bash-completion -y
apt-get install wget pwgen sudo openssh-server curl unzip nano zip dialog -y

# Network Tools
apt-get install rsync htop rsnapshot vnstat mtr iperf whois dnsutils strace ltrace -y

# Hapus aplikasi yang tidak dibutuhkan
apt-get purge exim4* rpcbind samba* -y

# set zona waktu  Jakarta
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

# karna ifconfig itu penting ;)
apt-get install net-tools -y

# nano Syntax highlight
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
cat >~/.nanorc <<'EOL'
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
EOL

find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

# Repository SURY
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Repostory mainline nginx
wget -qO - http://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb http://nginx.org/packages/mainline/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list

# Update list of available packages
apt-get update

# NGINX
apt-get install nginx -y
# default server block
cat >/etc/nginx/conf.d/default.conf <<'EOL'
server {
    listen       80;
    server_name  localhost;
    root   /usr/share/nginx/html;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php(?:$|/) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        fastcgi_intercept_errors on;
    }

}
EOL

# test nginx php fpm
# cek di IP-SERVER/info.php
echo "<?php  phpinfo();" > /usr/share/nginx/html/info.php

systemctl enable nginx
systemctl restart nginx

# PHP 7
apt-get install php7.3 php7.3-cli php7.3-common php7.3-gd php7.3-xmlrpc php7.3-fpm \
php7.3-curl php7.3-intl php-imagick php7.3-mysql php7.3-zip php7.3-xml php7.3-mbstring -y

sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Jakarta/g' /etc/php/7.3/fpm/php.ini
sed -i 's/disable_functions =/disable_functions =dl,exec,passthru,proc_open,proc_close,shell_exec,system/g' /etc/php/7.3/fpm/php.ini
sed -i 's/post_max_size \=\ 8M/post_max_size \=\ 80M/g' /etc/php/7.3/fpm/php.ini
sed -i 's/upload_max_filesize \=\ 2M/upload_max_filesize \=\ 80M/g' /etc/php/7.3/fpm/php.ini

# set PHP FPM sebagai nginx
sed -i "s/www-data/nginx/g" /etc/php/7.3/fpm/pool.d/www.conf

# aktifkan php fpm
systemctl enable php7.3-fpm
systemctl restart php7.3-fpm

# MySQL/MariaDB
apt-get install mariadb-server mariadb-client -y
MYSQL_ROOT_PASSWORD=$(pwgen 15 1)
systemctl enable mariadb
systemctl start mariadb
# MARIADB disable Unix Socket authentication
# https://mariadb.com/kb/en/library/authentication-plugin-unix-socket/

mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE test;"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "UPDATE mysql.user set plugin='' where User='root';"

systemctl restart mariadb

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

cat >/backup/mysql/backup-mysql.sh <<'EOL'
#!/bin/bash
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
EOL

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
echo "Server install selesai!"
echo "Password root MySQL: " "$MYSQL_ROOT_PASSWORD"
echo '----------------------'
