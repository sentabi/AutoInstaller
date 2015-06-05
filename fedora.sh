#!/usr/bin/env bash

## khusus 64 bit
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak 
## diinginkan

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update Repo dan Upgrade

dnf update -y
dnf upgrade -y

# RPM FUSION

wget http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-22.noarch.rpm  http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-22.noarch.rpm
dnf install rpmfusion*.rpm -y


# install aplikasi

dnf install firefox gimp inkscape terminator git puddletag pavucontrol -y

# install sublime 3

wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2
tar jxvf sublime_text_3_build_3083_x64.tar.bz2 
mv sublime_text_3 /opt
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime


# codec multimedia

dnf install gstreamer-plugins-* gstreamer1-* ffmpeg -y

# video player
dnf install vlc smplayer -y

# ekstrator 
dnf install file-roller-nautilus file-roller unzip unrar p7zip -y

# Browser dan Email Client
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf install google-chrome-stable_current_x86_64.rpm -y
dnf install thunderbird -y

# LibreOffice 
# hapus tanda pagar biar di install 
dnf install libreoffice

## LAMP 
dnf install httpd mariadb mariadb-server php php-pdo phpMyAdmin php-cli php-mysqlnd php-mcrypt php-xml

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

echo '
<?xml version="1.0"?>
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
</fontconfig>
' > /home/$USER/.fonts.conf
