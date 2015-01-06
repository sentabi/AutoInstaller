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
cp /etc/localtime

## ubah locale jadi US UTF8
locale-gen en_US.UTF-8

### install install untuk kebutuhan awal
apt-get install bsdutils 

