#!/usr/bin/env bash
 
## Fedora 22/23 64 bit
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak 
## diinginkan
 
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Hapus aplikasi yang ngga perlu 
dnf remove transmission claws-mail-* midori -y
dnf remove abrt-* -y

# Update Repo dan Upgrade
dnf update -y
dnf upgrade -y

# RPM FUSION
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y


# install aplikasi
dnf install gimp inkscape terminator git puddletag pavucontrol tigervnc nano wireshark nmap uget rfkill remmina remmina-plugins* openvpn -y

# Torrent Client 
dnf install deluge -y

# Password Manager 
dnf install keepassx -y

# ownCloud Client
dnf install owncloud-client -y

# install sublime 3
wget https://download.sublimetext.com/sublime_text_3_build_3114_x64.tar.bz2
tar jxvf sublime_text_3_build_*.tar.bz2 
mv sublime_text_3 /opt
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime

# XFCE
dnf install xfce4-mixer xfce4-volumed -y

# codec multimedia
dnf install  gstreamer-plugins-* gstreamer1-* ffmpeg youtube-dl -y
# Multimedia Player
dnf install vlc smplayer clementine -y

# VirtualBox
wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
#wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import -
dnf install dkms kernel-devel kernel-headers VirtualBox -y

# ekstrator 
dnf install file-roller-nautilus file-roller unzip unrar p7zip unrar -y

# Mount Android/Samba
dnf install libmtp-devel libmtp gvfs-mtp simple-mtpfs libusb gvfs-client gvfs-smb gvfs-fuse gigolo -y

# Browser dan Email Client
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf install google-chrome-stable_current_x86_64.rpm -y
dnf install thunderbird firefox -y
 
# LibreOffice 
dnf install libreoffice -y
 
## LAMP untu Web Development
dnf install httpd mariadb mariadb-server php php-pdo phpMyAdmin php-cli php-mysqlnd php-mcrypt php-xml -y

### Install Composer 
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer 

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

## Generate SSH Key
#ssh-keygen -b 4096 

# Font 
dnf install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm -y
wget http://font.ubuntu.com/download/ubuntu-font-family-0.83.zip
unzip ubuntu-font-family-0.83.zip
mv ubuntu-font-family-0.83 /usr/share/fonts/
wget https://github.com/downloads/adobe-fonts/source-code-pro/SourceCodePro_FontsOnly-1.013.zip
unzip SourceCodePro_FontsOnly-1.013.zip
mv SourceCodePro_FontsOnly-1.013 /usr/share/fonts/
