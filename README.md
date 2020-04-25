# Script AutoInstaller Linux

AutoInstaller dan auto auto-an. 

cek baik-baik scriptnya ;) karena otomatis menambahkan beberapa public key saya :)

Ganti link ke `id_rsa.pub` dengan public key anda. 

## Import Public Key
```
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys
```
## Cara Paklai
Sesuaiken ras distro si i pake

### Debian 
```
wget --no-check-certificate https://git.io/vvIPF -O debian.sh; chmod +x debian.sh; su -c "./debian.sh"
```

### Fedora

Download + install script
```
wget --no-check-certificate https://git.io/voUvT -O fedora.sh; chmod +x fedora.sh; su -c "./fedora.sh"
```

### Distro
Distro Linux si enggo i tes
- Debian 10 64 Bit
- Fedora 31,32 64 Bit
- Ubuntu 20.04 64 Bit

## PS1
**PS1** tergantung status serverna e, gelahna ula salah

Serper Online 
```
PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
```
Serper Offline/Serper Lokal
```
PS1="\[\e[1;30m\][\[\e[1;94m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
```
Komputer/PC
```
PS1="\[\e[1;30m\][\[\e[1;31m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
```

## Carana 
simpan salah sada baris sidatas kubas ~/.bashrc
```
echo 'PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "' >> ~/.bashrc
```
