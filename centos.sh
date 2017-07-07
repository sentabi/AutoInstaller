#!/usr/bin/env bash

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

# PS1
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

yum install wget curl nano -y

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

# public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys

yum clean all
yum update -y

yum install epel-release -y

yum install bash-completion net-tools rsnapshot htop vnstat iperf -y

# zona waktu Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

yum install rsync htop mtr curl unzip whois strace ltrace zip traceroute bind-utils -y

# Install Utility
yum install pwgen -y

yum install git -y

yum install fail2ban sendmail -y

# MariaDB
yum install mariadb-server mariadb -y

# PHP71
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install remi-release-7.rpm -y
yum install php71-php php71-php-cli php71-php-common php71-php-json php71-php-intl php71-php-mbstring php71-php-mcrypt php71-php-mysqlnd php71-php-pdo php71-php-tidy php71-php-xml php71-php-fpm -y

# Composer
curl -sS https://getcomposer.org/installer | php71
mv composer.phar /usr/bin/composer

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
mysql_secure_installation
systemctl restart mariadb
