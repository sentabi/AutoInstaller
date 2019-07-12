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

# Set Hostname
#hostnamectl --static set-hostname hostname.domain

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
echo '
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
include /usr/share/nano/nginx.nanorc
' >> ~/.nanorc
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
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
yum install rsync htop mtr curl unzip whois strace ltrace zip traceroute bind-utils -y
yum install pwgen -y
yum install git -y
yum install fail2ban sendmail -y

# MariaDB
echo '
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
' > /etc/yum.repos.d/MariaDB.repo
yum install mariadb-server mariadb -y

# PHP71
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install remi-release-7.rpm -y
yum install php71-php php71-php-cli php71-php-common php71-php-json php71-php-intl php71-php-mbstring php71-php-mcrypt php71-php-mysqlnd php71-php-pdo php71-php-tidy php71-php-xml php71-php-fpm -y

# Composer
curl -sS https://getcomposer.org/installer | php71
mv composer.phar /usr/bin/composer
ln -s /usr/bin/php71 /usr/local/bin/php

# nginx
echo '
[nginx.org]
name=nginx.org repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=1
enabled=1
' > /etc/yum.repos.d/nginx.repo;

rpm --import http://nginx.org/keys/nginx_signing.key
yum install nginx -y

sed -i 's/user = apache/user = nginx/g' /etc/opt/remi/php71/php-fpm.d/www.conf
sed -i 's/group = apache/user = nginx/g' /etc/opt/remi/php71/php-fpm.d/www.conf
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/opt/remi/php71/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Jakarta/g' /etc/opt/remi/php71/php.ini
sed -i "s/\memory_limit = .*/memory_limit = 1024M/" /etc/opt/remi/php71/php.ini

# nonaktifkan fungsi PHP
# sed -i 's/disable_functions =/disable_functions =dl,exec,passthru,proc_open,proc_close,shell_exec,system/g'
# listen = /run/php/php7.0-fpm.sock
# listen.owner = nginx
# listen.group = nginx
# listen.mode = 0660

# SSH
echo 'UseDNS no' >> /etc/ssh/sshd_config

systemctl enable nginx
systemctl enable mariadb
systemctl enable php71-php-fpm

systemctl start nginx
systemctl start mariadb
systemctl start php71-php-fpm

# Setting MariaDB
systemctl start mariadb

MYSQL_ROOT_PASSWORD=$(pwgen 15 1)

# MARIADB disable Unix Socket authentication
# https://mariadb.com/kb/en/library/authentication-plugin-unix-socket/

mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE test;"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "UPDATE mysql.user set plugin='' where User='root';"

echo '----------------------'
echo '| PENTING |'
echo '----------------------'

echo "Password root MySQL: " $MYSQL_ROOT_PASSWORD

echo "[client]
user = root
password = $MYSQL_ROOT_PASSWORD" > ~/.my.cnf

# restart mariadb agar perubahan diatas dijalankan
systemctl restart mariadb

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