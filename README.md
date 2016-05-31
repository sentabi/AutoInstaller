# Script AutoInstaller Linux

AutoInstaller dan auto auto-an. 

cek baik-baik scriptnya ;) karena otomatis menambahkan beberapa public key saya :)
Ganti link ke `id_rsa.pub` dengan public key anda. 

## Cara Penggunaan

Sesuaikan dengan distro anda. 
### Debian 
```
wget --no-check-certificate https://git.io/vvIPF 
```
ubah file permission agar bisa dieksekusi
```
chmod +x debian.sh
```
jalankan script
```
su -c "./debian.sh"
```

### Fedora

Download + install script
```
wget --no-check-certificate https://raw.githubusercontent.com/sentabi/AutoInstaller/master/fedora.sh
chmod +x fedora.sh
su -c "./fedora.sh"
```

## Distro
Distro Linux yang sudah di coba
- Debian 8 32/64
- Debian 7 32/64
- Fedora 22 32/64
- Fedora 23 32/64
