#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update Repo dan Upgrade

dnf clean all
dnf update
dnf upgrade 

# RPM FUSION

wget http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-22.noarch.rpm  http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-22.noarch.rpm
dnf install rpmfusion*.rpm 


# install aplikasi

dnf install firefox gimp inkscape terminator git 

# install sublime 3

wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3083_x64.tar.bz2
tar jxvf sublime_text_3_build_3083_x64.tar.bz2 
mv sublime_text_3 /opt
ln -s /opt/sublime_text_3/sublime_text /usr/bin/sublime


