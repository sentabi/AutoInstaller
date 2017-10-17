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
#set autoindent
syntax "comments" ".*"
color blue "^#.*"
set morespace
include /usr/share/nano/nginx.nanorc
' >> ~/.nanorc
wget https://raw.githubusercontent.com/scopatz/nanorc/master/nginx.nanorc -O /usr/share/nano/nginx.nanorc
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# public_key
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

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
sed -i 's/disable_functions =/disable_functions ="apache_child_terminate,apache_get_modules,apache_note,apache_setenv,define_syslog_variables,disk_free_space,disk_total_space,diskfreespace,dl,escapeshellarg,escapeshellcmd,exec,get_cfg_var,get_current_user,getcwd,getenv,getlastmo,getmygid,getmyinode,getmypid,getmyuid,ini_restore,ini_set,passthru,pcntl_alarm,pcntl_exec,pcntl_fork,pcntl_get_last_error,pcntl_getpriority,pcntl_setpriority,pcntl_signal,pcntl_signal_dispatch,pcntl_sigprocmask,pcntl_sigtimedwait,pcntl_sigwaitinfo,pcntl_strerrorp,pcntl_wait,pcntl_waitpid,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,pcntl_wifstopped,pcntl_wstopsig,pcntl_wtermsig,php_uname,phpinfo,popen,posix_getlogin,posix_getpwuid,posix_kill,posix_mkfifo,posix_setpgid,posix_setsid,posix_setuid,posix_ttyname,posix_uname,posixc,proc_close,proc_get_status,proc_nice,proc_open,proc_terminate,ps_aux,putenv,readlink,runkit_function_rename,shell_exec,show_source,symlink,syslog,system"/g'
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
mysql_secure_installation
systemctl restart mariadb
yum update -y
