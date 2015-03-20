#!/bin/bash
if [[ "$USER" != 'root' ]]; then
echo "Harus dijalankan sebagai root"
exit
fi

if [[ ! -e /etc/debian_version ]]; then
echo "Hanya bisa dijalankan di Debian atau turunannya"
exit
fi

## update repository dan sistem
apt-get clean all
apt-get update
apt-get upgrade -y

### update timezone  Jakarta
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

## ubah locale jadi US UTF8
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen en_US.UTF-8

### install install untuk kebutuhan awal
### install ca-certificates biar wget ga protest ERROR: The certificate of xxxxxx
apt-get install bsdutils bash-completion nano curl wget dialog ca-certificates

## PS1 
echo 'PS1="\[\e[1;30m\][\[\e[1;31m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
source ~/.bashrc

## mengamankan /tmp
rm -rf /tmp
mkdir /tmp
mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
chmod 1777 /tmp
echo "tmpfs   /tmp    tmpfs   rw,noexec,nosuid        0       0" >> /etc/fstab
rm -rf /var/tmp
ln -s /tmp /var/tmp  

## ganti port SSH [hardcode]
echo 'Port 38400
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile	%h/.ssh/authorized_keys
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
' > "/etc/ssh/sshd_config"
