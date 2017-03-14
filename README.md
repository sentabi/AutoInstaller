# Script AutoInstaller Linux

AutoInstaller dan auto auto-an. 

cek baik-baik scriptnya ;) karena otomatis menambahkan beberapa public key saya :)
Ganti link ke `id_rsa.pub` dengan public key anda. 

## Import Public Key
```
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/id_rsa.pub -O ~/.ssh/authorized_keys
```
## Cara Penggunaan

Sesuaikan dengan distro anda. 
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
Distro Linux yang sudah di coba
- Debian 7,8 64 Bit
- Fedora 24,25 64 Bit
