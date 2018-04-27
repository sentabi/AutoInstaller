#!/usr/bin/env bash
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak
## diinginkan
hostnamectl set-hostname --static fedora

USERSUDO=$SUDO_USER
if [[ $USERSUDO == 'root' || -z $USERSUDO ]]; then
    echo "--------------------------------------------"
    echo "Script ini harus dijalankan menggunakan sudo dan user biasa" 1>&2
    echo "Contoh : sudo -E bash ./fedora.sh" 1>&2
    echo "--------------------------------------------"
    exit 1
fi

dnf install wget -y

# Sinkronisasi zona waktu WIB
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

dnf install chrony -y
systemctl enable chronyd
systemctl start chronyd

# Hapus aplikasi yang ngga perlu
dnf remove transmission* claws-mail* midori pidgin -y
dnf remove abrt-* -y

# .bashrc
sudo -u "$USERSUDO" bash -c "rm -f /home/$USERSUDO/.bashrc"
sudo -u "$USERSUDO" bash -c "wget https://raw.githubusercontent.com/sentabi/AutoInstaller/master/bashrc -O /home/$USERSUDO/.bashrc"
sudo -u "$USERSUDO" bash -c "source /home/$USERSUDO/.bashrc"

# 3rd party repo
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm -y
dnf install kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig -y

# Update Repo dan Upgrade
dnf upgrade -y

# install aplikasi
dnf install aria2  vnstat terminator git  pavucontrol tigervnc nano wireshark lshw nmap uget rfkill openvpn -y

dnf install gimp inkscape puddletag shotwell remmina remmina-plugins* -y

# nano Syntax highlight
sudo -u "$USERSUDO" bash -c "find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc"

# Torrent Client
dnf install deluge -y

# Password Manager
dnf install keepassxc pwgen -y

# ownCloud Client
# TODO
# versi Fedora jangan di hardcode
#dnf config-manager --add-repo https://download.opensuse.org/repositories/isv:ownCloud:desktop/Fedora_26/isv:ownCloud:desktop.repo
dnf install owncloud-client -y

# install sublime 3
FOLDERSUBLIME=/opt/sublime_text_3
if [ ! -d "$FOLDERSUBLIME" ]
    then
        wget https://download.sublimetext.com/sublime_text_3_build_3143_x64.tar.bz2
        tar jxvf sublime_text_3_build_*.tar.bz2
        mv sublime_text_3 /opt
        ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime
        rm -fr sublime_text sublime_text_3_build_3143_x64.tar.bz2
    else
        echo "Folder $FOLDERSUBLIME sudah ada. Instalasi sublime gagal."
fi
# XFCE
dnf install xfce4-pulseaudio-plugin bluebird-gtk3-theme bluebird-gtk2-theme bluebird-xfwm4-theme -y

# codec multimedia
dnf install ffmpeg gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras -y
dnf groupinstall Multimedia -y

# Downloader Youtube
wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# Multimedia Player
dnf install vlc smplayer mplayer mpv clementine -y

# VirtualBox
FILEREPOVIRTUALBOX=/etc/yum.repos.d/virtualbox.repo
if [ ! -f "$FILEREPOVIRTUALBOX" ]
    then
        wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import -
fi
dnf install VirtualBox -y
usermod -a -G vboxusers "$USERSUDO"

# ekstrator
dnf install file-roller unzip p7zip unrar -y

# Mount Android/Samba
dnf install libmtp-devel libmtp gvfs-mtp simple-mtpfs libusb gvfs-client gvfs-smb gvfs-fuse gigolo -y
dnf install samba samba-common samba-client -y

# Browser dan Email Client
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf install google-chrome-stable_current_x86_64.rpm -y
rm -f google-chrome-stable_current_x86_64.rpm
dnf install thunderbird firefox -y

# Utility
yum install rsync htop mtr rsnapshot curl vnstat unzip whois iperf curl strace sysstat ltrace zip traceroute bind-utils -y

# LibreOffice
dnf install libreoffice -y

# Telegram
# Telegram otomatis membuat shortcut, jadi tidak perlu dibuat lagi
cd /opt;
wget --content-disposition  https://telegram.org/dl/desktop/linux
tar xJvf tsetup.*.tar.xz
ln -s /opt/Telegram/Telegram /usr/bin/telegram
rm -fr tsetup.*.tar.xz

# DLL
dnf install xclip -y

## Font Rendering
echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="font">
<edit name="autohint" mode="assign">
<bool>true</bool>
</edit>
</match>
</fontconfig>' > /etc/fonts/conf.d/99-autohinter-only.conf
ln -s /etc/fonts/conf.avail/10-autohint.conf /etc/fonts/conf.d/
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/

echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <match target="font" >
  <edit mode="assign" name="autohint" >
   <bool>true</bool>
  </edit>
 </match>
 <match target="font" >
  <edit mode="assign" name="rgba" >
   <const>none</const>
  </edit>
 </match>
 <match target="font" >
  <edit mode="assign" name="hinting" >
   <bool>false</bool>
  </edit>
 </match>
 <match target="font" >
  <edit mode="assign" name="hintstyle" >
   <const>hintnone</const>
  </edit>
 </match>
 <match target="font" >
  <edit mode="assign" name="antialias" >
   <bool>true</bool>
  </edit>
 </match>
</fontconfig>' > sudo -u "$USERSUDO" tee /home/"$USERSUDO"/.fonts.conf > /dev/null

sudo -u "$USERSUDO" bash -c 'echo "Xft.lcdfilter: lcddefault"' > /home/"$USERSUDO"/.Xresources

## Generate SSH Key
# ssh-keygen -b 4096

# Font
dnf install freetype-freeworld -y
dnf install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm -y

wget https://assets.ubuntu.com/v1/fad7939b-ubuntu-font-family-0.83.zip
unzip fad7939b-ubuntu-font-family-0.83.zip
mv fad7939b-ubuntu-font-family-0.83 /usr/share/fonts/

wget https://github.com/downloads/adobe-fonts/source-code-pro/SourceCodePro_FontsOnly-1.013.zip
unzip SourceCodePro_FontsOnly-1.013.zip
mv SourceCodePro_FontsOnly-1.013 /usr/share/fonts/

rm -fr SourceCodePro_FontsOnly* ubuntu-font-family-*

# Tweak XFCE
su "$USERSUDO" -m -c 'xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -n -t bool -s false'
su "$USERSUDO" -m -c 'xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -n -t string -s "ibus-hangul"'
su "$USERSUDO" -m -c 'xfconf-query -c xfwm4 -p /general/theme -s "Bluebird"'
su "$USERSUDO" -m -c 'xfconf-query -c xsettings -p /Net/ThemeName -s "Glossy"'

# Disable Selinux. Enable setelah semua di testing ;)
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

# Mengamankan /tmp
# cd ~
# rm -rf /tmp
# mkdir /tmp
# mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
# chmod 1777 /tmp
# echo "tmpfs   /tmp    tmpfs   rw,noexec,nosuid        0       0" >> /etc/fstab
# rm -rf /var/tmp
# ln -s /tmp /var/tmp

# Batasi ukuran log systemd
echo '
Storage=persistent
SystemMaxUse=400M
SystemMaxFileSize=30M
RuntimeMaxUse=250M
RuntimeMaxFileSize=30M' >> /etc/systemd/journald.conf
# restart systemd
systemctl restart systemd-journald

# SSH
echo "UseDNS no" >> /etc/ssh/sshd_config

## LAMP untu Web Development
dnf install httpd mariadb mariadb-server php php-pdo phpMyAdmin php-cli php-mysqlnd php-mcrypt php-xml -y

# Buat baru file /var/tmp
# Biar ga error https://jaranguda.com/solusi-mariadb-failed-at-step-namespace-spawning/
rm -fr /var/tmp
mkdir /var/tmp
chmod 1777 /var/tmp

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
mysql -e "UPDATE mysql.user set plugin='' where user='root';"

echo "[client]
user = root
password = $MYSQL_ROOT_PASSWORD" | sudo -u "$USERSUDO" tee /home/"$USERSUDO"/.my.cnf > /dev/null

systemctl restart mariadb

## Login permanen ke phpMyAdmin dari localhost
# TODO
# replace baris ini bukan di delete, lalu tambah baru.

sed -i "/'cookie'/d" /etc/phpMyAdmin/config.inc.php
sed -i "/'user'/d" /etc/phpMyAdmin/config.inc.php
sed -i "/'password'/d" /etc/phpMyAdmin/config.inc.php
sed -i "/?>/d" /etc/phpMyAdmin/config.inc.php

echo "
\$cfg['Servers'][\$i]['auth_type']     = 'config';    // Authentication method (config, http or cookie based)?
\$cfg['Servers'][\$i]['user']          = 'root';          // MySQL user
\$cfg['Servers'][\$i]['password']      = '$MYSQL_ROOT_PASSWORD';          // MySQL password (only needed
" >> /etc/phpMyAdmin/config.inc.php

chown "$USERSUDO":"$USERSUDO" -R /var/www

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Tweak
sed -i 's/AllowOverride None/AllowOverride All/g'  /etc/httpd/conf/httpd.conf

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

# Speedtest CLI
wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py -O /usr/bin/speedtest
chmod +x /usr/bin/speedtest
