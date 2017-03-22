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
# public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys

yum clean all
yum update -y

yum install epel-release -y

yum install rsnapshot htop vnstat iperf -y
# zona waktu Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

yum install rsync htop mtr unzip whois strace ltrace zip traceroute bind-utils -y
yum install pwgen -y
yum install git -y

yum install fail2ban sendmail -y

yum install mariadb-server mariadb -y

#service mariadb restart
#mysql_secure_installation
#service mariadb restart

#rpm -Ivh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
#yum install php71 -y
