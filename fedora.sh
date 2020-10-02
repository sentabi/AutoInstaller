#!/usr/bin/env bash
## jangan asal di jalankan, liat dulu scriptna untuk menghindari hal-hal yang tidak
## diinginkan

# Set Zona Waktu WIB
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

waktuMulai=$(date)

# Set hostname
if ! [[ -z "$1" ]]; then
        hostnamectl set-hostname --static $1
else
        hostnamectl set-hostname --static fedora
fi

# Generate SSH Key tanpa password
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q

USERSUDO=$SUDO_USER
if [[ $USERSUDO == 'root' || -z $USERSUDO ]]; then
    echo "--------------------------------------------"
    echo "Script ini harus dijalankan menggunakan sudo dan user biasa" 1>&2
    echo "Contoh : sudo -E bash ./fedora.sh fedoraku" 1>&2
    echo "--------------------------------------------"
    exit 1
fi

# Hapus aplikasi yang ngga perlu
dnf remove transmission* claws-mail* abrt-* midori pidgin -y

# 3rd party repo
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
dnf install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm -y

# Update Repo dan Upgrade
dnf upgrade -y

# install kernel-devel dkk untuk compile
dnf install kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig -y

# install aplikasi
dnf install sshpass pavucontrol nano wget curl lshw rfkill mediawriter puddletag sshfs -y

# GIT
dnf install git -y

# OpenVPN
dnf install openvpn -y

# VNC tools
dnf install tigervnc remmina remmina-plugins* -y

# Design
dnf install shotwell gimp inkscape -y

# Debugging tools
dnf install wireshark nmap strace sysstat ltrace -y

# Utility
dnf install rsnapshot wavemon -y

# CLI TOOLS
dnf install mtr rsync htop whois iperf iperf3 traceroute bind-utils -y

# git prompt
wget https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh

# .bashrc
sudo -u "$USERSUDO" bash -c "rm -f /home/$USERSUDO/.bashrc"
sudo -u "$USERSUDO" bash -c "wget https://raw.githubusercontent.com/sentabi/AutoInstaller/master/bashrc -O /home/$USERSUDO/.bashrc"


# nano Syntax highlight
sudo -u "$USERSUDO" bash -c "find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc"

# Torrent Client
dnf install qbittorrent -y

# Download manager
dnf install uget aria2 -y

# Password Manager
dnf install keepassxc pwgen -y

# Nextcloud client
dnf install nextcloud-client -y

# screenshoot tools
dnf install shutter -y

# XFCE
dnf install xfce4-pulseaudio-plugin bluebird-gtk3-theme bluebird-gtk2-theme bluebird-xfwm4-theme -y

# codec multimedia
dnf install ffmpeg gstreamer1-plugins-base gstreamer1-plugins-good-extras gstreamer1-vaapi \
            gstreamer1-plugins-good gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free \
            gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-extras -y

# HTML 5 / h264 Firefox
dnf config-manager --set-enabled fedora-cisco-openh264
dnf install gstreamer1-plugin-openh264 mozilla-openh264 compat-ffmpeg28 -y

# Downloader Youtube
wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# Multimedia Player
dnf install vlc smplayer mplayer mpv clementine -y

# install VirtualBox
FILEREPOVIRTUALBOX=/etc/yum.repos.d/virtualbox.repo
VIRTUALBOX_LATEST_VERSION=$(wget -qO- https://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT | grep -oE '^[0-9]{1}.[0-9]{1}')
if [ ! -f "$FILEREPOVIRTUALBOX" ]
    then
        wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
        rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
fi
dnf install VirtualBox-${VIRTUALBOX_LATEST_VERSION} -y
usermod -a -G vboxusers "$USERSUDO"

# install Sublime Text 3
FOLDERSUBLIME=/opt/sublime_text_3
SUBLIME_LATEST_VERSION=$(curl -s https://www.sublimetext.com/updates/3/stable/updatecheck | grep latest_version | cut -d ':' -f2 | sed 's/[^0-9]*//g')

if [ ! -d "$FOLDERSUBLIME" ]
    then
        wget "https://download.sublimetext.com/sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2"
        tar jxvf sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2 -C /opt
        ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime
        rm -f "sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2"
    else
        SUBLIME_INSTALLED_VERSION=$(sublime --version | cut -d ' ' -f4)
        if [[ $SUBLIME_LATEST_VERSION -gt $SUBLIME_INSTALLED_VERSION ]]; then
            rm -fr $FOLDERSUBLIME
            wget "https://download.sublimetext.com/sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2"
            tar jxvf sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2 -C /opt
            rm -f "sublime_text_3_build_${SUBLIME_LATEST_VERSION}_x64.tar.bz2"
        else
            echo "Saat ini anda sudah menggunakan Sublime Text versi terbaru (${SUBLIME_LATEST_VERSION})"
        fi
fi


# ekstrator
dnf install file-roller zip unzip p7zip unrar -y

# Mount Android
dnf install libmtp-devel libmtp gvfs-mtp simple-mtpfs libusb gvfs-client gvfs-smb gvfs-fuse gigolo -y

# Install SAMBA
dnf install samba samba-common samba-client -y

# Install Google Chrome
dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y

# Install Thunderbird
dnf install thunderbird -y

# LibreOffice
dnf install libreoffice -y

# DLL
dnf install xclip gpg -y

## Font Rendering
cat >/etc/fonts/conf.d/99-autohinter-only.conf <<'EOL'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="font">
<edit name="autohint" mode="assign">
<bool>true</bool>
</edit>
</match>
</fontconfig>
EOL

ln -s /etc/fonts/conf.avail/10-autohint.conf /etc/fonts/conf.d/
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/

cat >/home/"$USERSUDO"/.fonts.conf <<'EOL'
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
EOL

sudo -u "$USERSUDO" bash -c 'echo "Xft.lcdfilter: lcddefault"' > /home/"$USERSUDO"/.Xresources


# Font
dnf install freetype-freeworld -y

TMP_FONT_FOLDER=$(mktemp)

cd $TMP_FONT_FOLDER
OVERPASS_LATEST=$(curl -s https://github.com/RedHatOfficial/Overpass/releases/latest | sed 's#.*tag/\(.*\)\".*#\1#' | sed 's/v//1')

wget https://assets.ubuntu.com/v1/fad7939b-ubuntu-font-family-0.83.zip -O ubuntu.zip
unzip ubuntu.zip
mv ubuntu-font-family-* /usr/share/fonts/

wget https://github.com/RedHatBrand/Overpass/archive/3.0.3.tar.gz -O overpass.tar.gz
tar zxvf overpass.tar.gz
mv Overpass-* /usr/share/fonts/

wget https://github.com/downloads/adobe-fonts/source-code-pro/SourceCodePro_FontsOnly-1.013.zip -O sourcecodepro.zip
unzip sourcecodepro.zip
mv SourceCodePro_FontsOnly-* /usr/share/fonts/

rm -fr "$TMP_FONT_FOLDER"

# tweak font
dnf copr enable dawid/better_fonts -y
dnf install fontconfig-enhanced-defaults fontconfig-font-replacements -y

# Tweak XFCE
su "$USERSUDO" -m -c 'xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -n -t bool -s false'
su "$USERSUDO" -m -c 'xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -n -t string -s "ibus-hangul"'
su "$USERSUDO" -m -c 'xfconf-query -c xfwm4 -p /general/theme -s "Bluebird"'
su "$USERSUDO" -m -c 'xfconf-query -c xsettings -p /Net/ThemeName -s "Glossy"'

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
dnf install httpd mariadb mariadb-server phpMyAdmin php php-pdo php-cli php-mysqlnd php-mcrypt php-xml -y

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
# mysql -e "UPDATE mysql.user set plugin='' where user='root';"

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

# Telegram
wget --content-disposition -q https://telegram.org/dl/desktop/linux -O tsetup.tar.xz
tar xJvf tsetup.tar.xz -C /opt
rm -f tsetup.tar.xz

echo "Install selesai!"
echo "Mulai dijalankan $waktuMulai"
echo "Selesai $(date)"
