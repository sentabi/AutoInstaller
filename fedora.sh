#!/usr/bin/env bash
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak
## diinginkan

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

dnf install wget -y

# Sinkronisasi Zona waktu WIB
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

dnf install chrony -y
systemctl enable chronyd
systemctl start chronyd

# Hapus aplikasi yang ngga perlu
dnf remove transmission* claws-mail* midori pidgin -y
dnf remove abrt-* -y

# .bashrc
wget https://raw.githubusercontent.com/sentabi/scripts/master/bashrc;
rm -f /home/$USER/.bashrc;
mv bashrc /home/$USER/.bashrc;
source /home/$USER/.bashrc;

# 3rd party repo
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm -y

# Update Repo dan Upgrade
dnf upgrade -y

# install aplikasi
dnf install aria2 gimp inkscape vnstat terminator git puddletag pavucontrol tigervnc shotwell nano wireshark lshw nmap uget rfkill remmina remmina-plugins* openvpn -y

# nano Syntax highlight
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc

# Torrent Client
dnf install deluge -y

# Password Manager
dnf install keepassx pwgen -y

# ownCloud Client
dnf install owncloud-client -y

# install sublime 3
wget https://download.sublimetext.com/sublime_text_3_build_3143_x64.tar.bz2
tar jxvf sublime_text_3_build_*.tar.bz2
mv sublime_text_3 /opt
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime

# XFCE
dnf install xfce4-pulseaudio-plugin bluebird-gtk3-theme bluebird-gtk2-theme bluebird-xfwm4-theme -y

# codec multimedia
dnf install libwbclient-devel gstreamer-plugins-* gstreamer1-* ffmpeg youtube-dl -y

# Multimedia Player
dnf install vlc smplayer mplayer mpv clementine -y

# VirtualBox
wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import -
dnf install gcc make dkms kernel-devel-$(uname -r) kernel-headers VirtualBox-5.1 -y

usermod -a -G vboxusers $USER

# ekstrator
dnf install file-roller unzip unrar p7zip unrar -y

# Mount Android/Samba
dnf install libmtp-devel libmtp gvfs-mtp simple-mtpfs libusb gvfs-client gvfs-smb gvfs-fuse gigolo -y

# Browser dan Email Client
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf install google-chrome-stable_current_x86_64.rpm -y
dnf install thunderbird firefox -y

# Utility
yum install rsync htop mtr rsnapshot curl vnstat unzip whois iperf curl strace sysstat ltrace zip traceroute bind-utils -y

# LibreOffice
dnf install libreoffice -y

# Telegram
# Telegram otomatis membuat shortcut, jadi tidak perlu dibuat lagi
cd /opt;
wget --content-disposition https://tdesktop.com/linux
tar xJvf tsetup.*.tar.xz
ln -s /opt/Telegram/Telegram /usr/bin/telegram

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
</fontconfig>' > /home/$USER/.fonts.conf

echo "Xft.lcdfilter: lcddefault" > /home/$USER/.Xresources

## Generate SSH Key
# ssh-keygen -b 4096

# Font
dnf install freetype-freeworld -y
dnf install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm -y
wget http://font.ubuntu.com/download/ubuntu-font-family-0.83.zip
unzip ubuntu-font-family-0.83.zip
mv ubuntu-font-family-0.83 /usr/share/fonts/
wget https://github.com/downloads/adobe-fonts/source-code-pro/SourceCodePro_FontsOnly-1.013.zip
unzip SourceCodePro_FontsOnly-1.013.zip
mv SourceCodePro_FontsOnly-1.013 /usr/share/fonts/

# Tweak XFCE
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s "false"
xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -s "ibus-hangul"
xfconf-query -c xfwm4 -p /general/theme -s "Bluebird"
xfconf-query -c xsettings -p /Net/ThemeName -s "Glossy"

# Disable Selinux. Enable setelah semua di testing ;)
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

# Mengamankan /tmp
cd ~
rm -rf /tmp
mkdir /tmp
mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
chmod 1777 /tmp
echo "tmpfs   /tmp    tmpfs   rw,noexec,nosuid        0       0" >> /etc/fstab
rm -rf /var/tmp
ln -s /tmp /var/tmp

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

# Setting MariaDB
systemctl start mariadb
mysql_secure_installation
systemctl restart mariadb

# setting login permanen phpmyadmin di localhost
# https://jaranguda.com/login-permanent-phpmyadmin/

## Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer
