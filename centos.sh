#!/usr/bin/env bash
# contoh : ./centos.sh server-centos
# install php mysql nginx

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi

if [[ ! -e /etc/centos-release ]]; then
    echo "Hanya bisa dijalankan di CentOS"
    exit
fi

# Set hostname
if ! [[ -z "$1" ]]; then
        hostnamectl set-hostname --static $1
else
        hostnamectl set-hostname --static centos
fi

# selinux off ;
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

# firewall off ;)
systemctl stop firewalld
systemctl disable firewalld

# PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

yum install wget curl nano -y

# nano Syntax highlight
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
cat >~/.nanorc <<'EOL'
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
EOL

find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

yum clean all
yum update -y

yum install epel-release -y

yum install bash-completion net-tools rsnapshot htop vnstat iperf -y

# zona waktu Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# otomatis sync waktu
yum install chrony -y
systemctl start chronyd
systemctl enable chronyd

# Install Utility
yum install rsync htop mtr curl unzip whois strace ltrace zip traceroute bind-utils \
    pwgen git fail2ban sendmail -y

# MariaDB
cat >/etc/yum.repos.d/MariaDB.repo <<'EOL'
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOL

yum install MariaDB-server MariaDB-client -y

# PHP 7.3
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum install php73-php php73-php-cli php73-php-common php73-php-json php73-php-intl \
    php73-php-mbstring php73-php-mcrypt php73-php-mysqlnd php73-php-pdo \
    php73-php-tidy php73-php-xml php73-php-fpm -y

# Composer
curl -sS https://getcomposer.org/installer | php73
mv composer.phar /usr/bin/composer
ln -s /usr/bin/php73 /usr/local/bin/php

# nginx
cat >/etc/yum.repos.d/nginx.repo <<'EOL'
[nginx.org]
name=nginx.org repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
EOL

rpm --import http://nginx.org/keys/nginx_signing.key

yum install nginx -y

# folder root nginx
mkdir -p /var/www/

# default server nginx
cat >/etc/nginx/conf.d/default.conf <<'EOL'
server {
    listen       80;
    server_name  centos default_server;
    root   /var/www/;

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
        fastcgi_pass unix:/var/opt/remi/php73/run/php-fpm/php73-php-fpm.sock;
        fastcgi_intercept_errors on;
    }

}
EOL

# test nginx php fpm
# cek di IP-SERVER/info.php
echo "<?php  phpinfo();" > /var/www/info.php

sed -i 's/user = apache/user = nginx/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/opt\/remi\/php73\/run\/php-fpm\/php73-php-fpm.sock/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/opt/remi/php73/php-fpm.d/www.conf
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/opt/remi/php73/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Jakarta/g' /etc/opt/remi/php73/php.ini
sed -i "s/\memory_limit = .*/memory_limit = 1024M/" /etc/opt/remi/php73/php.ini
sed -i 's/disable_functions =/disable_functions =dl,exec,passthru,proc_open,proc_close,shell_exec,system/g' /etc/opt/remi/php73/php.ini

# SSH
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Setting MariaDB
MYSQL_ROOT_PASSWORD=$(pwgen 15 1)

# securing MariaDB
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE test;"
mysql -e "FLUSH PRIVILEGES;"

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

# Aktifkan nginx mariadb php sewaktu reboot
systemctl enable nginx
systemctl enable mariadb
systemctl enable php73-php-fpm

# jalankan nginx mariadb php
systemctl start nginx
systemctl start mariadb
systemctl start php73-php-fpm

# password root
echo '----------------------'
echo "Server install selesai!"
echo "Password root MySQL: " "$MYSQL_ROOT_PASSWORD"
echo '----------------------'