#!/usr/bin/env bash
 
## Fedora 22/23 64 bit
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak 
## diinginkan

LOG=/tmp/fedora.log

# hapus log yang sudah ada
rm -f $LOG
touch $LOG

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Hapus aplikasi yang ngga perlu 
dnf remove transmission claws-mail-* midori pidgin -y | tee -a $LOG
dnf remove abrt-* -y | tee -a $LOG

# Update Repo dan Upgrade
dnf clean all | tee -a $LOG
dnf update -y | tee -a $LOG
dnf upgrade -y | tee -a $LOG

# RPM FUSION
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y | tee -a $LOG


# install aplikasi
dnf install gimp inkscape vnstat terminator git puddletag pavucontrol tigervnc shotwell htop nano wireshark nmap uget rfkill remmina remmina-plugins* openvpn -y | tee -a $LOG

# Torrent Client 
dnf install deluge -y | tee -a $LOG

# Password Manager 
dnf install keepassx -y | tee -a $LOG

# ownCloud Client
dnf install owncloud-client -y | tee -a $LOG

# install sublime 3
wget https://download.sublimetext.com/sublime_text_3_build_3114_x64.tar.bz2 | tee -a $LOG 
tar jxvf sublime_text_3_build_*.tar.bz2 | tee -a $LOG
mv sublime_text_3 /opt
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime

# XFCE
dnf install xfce4-mixer xfce4-volumed bluebird-gtk3-theme bluebird-gtk2-theme bluebird-xfwm4-theme y | tee -a $LOG

# codec multimedia
dnf install  gstreamer-plugins-* gstreamer1-* ffmpeg youtube-dl -y | tee -a $LOG
# Multimedia Player
dnf install vlc smplayer clementine -y | tee -a $LOG

# VirtualBox
wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo | tee -a $LOG
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import - | tee -a $LOG
dnf install gcc make dkms kernel-devel-$(uname -r) kernel-headers VirtualBox-5.1 -y | tee -a $LOG

# ekstrator 
dnf install file-roller-nautilus file-roller unzip unrar p7zip unrar -y | tee -a $LOG

# Mount Android/Samba
dnf install libmtp-devel libmtp gvfs-mtp simple-mtpfs libusb gvfs-client gvfs-smb gvfs-fuse gigolo -y | tee -a $LOG

# Browser dan Email Client
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm | tee -a $LOG
dnf install google-chrome-stable_current_x86_64.rpm -y | tee -a $LOG
dnf install thunderbird firefox -y | tee -a $LOG

# network 
dnf install mtr -y | tee -a $LOG

# LibreOffice 
dnf install libreoffice -y | tee -a $LOG
 
## LAMP untu Web Development
dnf install httpd mariadb mariadb-server php php-pdo phpMyAdmin php-cli php-mysqlnd php-mcrypt php-xml -y | tee -a $LOG

### Install Composer 
curl -sS https://getcomposer.org/installer | php | tee -a $LOG
mv composer.phar /usr/bin/composer | tee -a $LOG

## Font Rendering
echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="font">
<edit name="autohint" mode="assign">
<bool>true</bool>
</edit>
</match>
</fontconfig>' > /etc/fonts/conf.d/99-autohinter-only.conf | tee -a $LOG
ln -s /etc/fonts/conf.avail/10-autohint.conf /etc/fonts/conf.d/ | tee -a $LOG
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/ | tee -a $LOG
 
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
</fontconfig>' > /home/$USER/.fonts.conf | tee -a $LOG

## Generate SSH Key
ssh-keygen -b 4096 

# Font 
dnf install freetype-freeworld -y | tee -a $LOG
dnf install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm -y | tee -a $LOG
wget http://font.ubuntu.com/download/ubuntu-font-family-0.83.zip | tee -a $LOG
unzip ubuntu-font-family-0.83.zip | tee -a $LOG
mv ubuntu-font-family-0.83 /usr/share/fonts/ | tee -a $LOG
wget https://github.com/downloads/adobe-fonts/source-code-pro/SourceCodePro_FontsOnly-1.013.zip | tee -a $LOG
unzip SourceCodePro_FontsOnly-1.013.zip | tee -a $LOG
mv SourceCodePro_FontsOnly-1.013 /usr/share/fonts/ | tee -a $LOG

# Tweak XFCE 
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s "false"
xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -s "ibus-hangul"
xfconf-query -c xfwm4 -p /general/theme -s "Bluebird"
xfconf-query -c xsettings -p /Net/ThemeName -s "Glossy"

dnf remove xfce4-pulseaudio-plugin
dnf install xfce4-volumed

# Disable Selinux. Enable setelah semua di testing ;)
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config 
